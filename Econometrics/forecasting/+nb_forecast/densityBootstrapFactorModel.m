function [Y,XE,solution] = densityBootstrapFactorModel(y0,restrictions,model,options,results,nSteps,iter,inputs,solution)
% Syntax:
%
% [Y,XE,solution] = nb_forecast.densityBootstrapFactorModel(y0,...
%           restrictions,model,options,results,nSteps,iter,inputs,solution)
%
% Description:
%
% Produce density forecast of a factor model using bootstrap.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(inputs.missing)
        error([mfilename ':: Density forecast of factor models that are estimated with missing '...
            'observations are not yet supported. Contact Kenneth S. Paulsen if needed.'])
    end

    if strcmpi(model.class,'nb_fmsa')
        [Y,XE] = nb_forecast.densityBootstrapStepAheadFactorModel(y0,restrictions,model,options,results,nSteps,iter,inputs);
        return
    end

    % Only allow one identification per posterior draws?
    if isfield(model,'identification')
        model.identification.draws = 1;
    end
    
    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    method         = inputs.method;
    try options    = options(iter); catch; end %#ok<CTCH>

    % Get the function to use to solve the model
    if options.recursive_estim 
        if parameterDraws == 1
            func = str2func([model.class, '.solveRecursive']);
        else
            func = str2func([model.class, '.solveNormal']);
        end
    else
        func = str2func([model.class, '.solveNormal']);
    end
    
    % Preallocate memory
    nVars    = size(y0,1);
    Y        = nan(nVars,nSteps + 1,parameterDraws*draws);
    Y(:,1,:) = y0(:,:,ones(1,parameterDraws*draws));
    nObs     = length(inputs.observables);
    Z        = nan(nObs,nSteps + 1,parameterDraws*draws);
    
    % Produce forecast
    %----------------------------------------------------------------------
    const = ones(1,nSteps+1);
    if parameterDraws == 1 % Only residual uncertainty
        
        if restrictions.type ~= 3 || ~restrictions.softConditioning
            % No identification even for VARs when not conditional 
            % forecast!
            model = func(results,options); 
        end
        
        % Get model solution
        [A,B,C,vcv,~] = nb_forecast.getModelMatrices(model,iter);
        
        % Make draws from the distributions of the exogenous and the shocks
        [E,X,solution] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,[],[],vcv,nSteps,draws,restrictions,solution,inputs,options);
        
        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        for jj = 1:draws
            Y(:,:,jj) = nb_computeForecast(A,B,C,Y(:,:,jj),X(:,:,jj),E(:,:,jj));
        end
        
        if ~isempty(inputs.observables) 
            
            if strcmpi(model.class,'nb_fm')
                indF = strncmpi(model.exo,'Factor',6);
                F    = X(indF,:,:);
                Fac  = [nan(size(F,1),1,size(F,3)),F];
            elseif strcmpi(model.class,'nb_favar')
                numDep = length(options.dependent) + length(options.factors);
                Fac    = Y(1:numDep,:,:);
            else
                [~,indF2] = ismember(options.factors,model.endo);
                Fac       = Y(indF2,:,:);
            end
            
            % Shrink to the observables of interest
            [~,ind] = ismember(inputs.observables,model.observables);
            F       = model.F(ind,:,iter);
            G       = model.G(ind,:,iter);
            R       = model.R(ind,ind,iter);
            for jj = 1:draws
                U         = nb_forecast.multvnrnd(R,nSteps+1);
                Z(:,:,jj) = F*const + G*Fac(:,:,jj) + U; % Observation equation, should I draw here to? What about factor uncertainty?
            end
            
        end
        
    else
        
        E = nan(length(model.res),nSteps,parameterDraws*draws);
        X = nan(length(model.exo),nSteps,parameterDraws*draws);
    
        % Then we loop through each parameter set
        %......................................................................
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs);
        
        % Make the parameter draws
        %..........................
        if isfield(options,'factorsLags')
            maxLag = max(options.factorsLags,max(options.nLags));
        else
            maxLag = options.nLags;
        end
        options.stdType   = method;
        options.stdReplic = parameterDraws;
        [betaDraws,lambdaDraws,sigmaDraws,RDraws,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,iter);   

        % Get the initial values of the drawn factors
        factorDraws = factorDraws(end-maxLag+1:end,:,:);
        [s1,s2,s3]  = size(factorDraws);
        factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
        factorDraws = permute(factorDraws,[2,1,3]);
        factors     = [options.factors,nb_cellstrlag(options.factors,maxLag-1,'varFast')];
        [~,indF]    = ismember(factors,model.endo);
        [~,indF2]   = ismember(options.factors,model.endo);
                
        % Loop through the parameter draws and produce density forecast
        kk   = 0;
        ii   = 0;
        jj   = 0;
        res  = results;
        note = nb_when2Notify(parameterDraws);
        while kk < parameterDraws
            
            ii = ii + 1;
            jj = jj + 1;

            if ii > parameterDraws
                
                % Draw new bootstraped parameters and factors
                options.stdReplic = round(parameterDraws*inputs.newDraws);
                [betaDraws,lambdaDraws,sigmaDraws,RDraws,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,iter); 
                factorDraws = factorDraws(end-maxLag+1:end,:,:);
                [s1,s2,s3]  = size(factorDraws);
                factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
                factorDraws = permute(factorDraws,[2,1,3]);
                
            end
            
            res.beta   = betaDraws(:,:,ii);
            res.sigma  = sigmaDraws(:,:,ii);
            res.lambda = lambdaDraws(:,:,ii);
            res.R      = RDraws(:,:,ii);
                
            % Solve the model given the posterior draw
            func = str2func([model.class, '.solveNormal']);
            if restrictions.type == 3 || restrictions.softConditioning
                try
                    if isfield(model,'identification')
                        modelDraw = func(res,options,model.identification);
                    else
                        modelDraw = func(res,options);
                    end
                catch %#ok<CTCH>
                    continue
                end
            else
                % No identification even for VARs when not conditional 
                % forecast!
                modelDraw = func(res,options); % No identification even for VARs! 
            end

            if inputs.stabilityTest
                [~,~,modulus] = nb_calcRoots(modelDraw.A);
                if any(modulus > 1)
                    continue
                end
            end 
            
            % Get model solution
            [A,B,C,vcv,~] = nb_forecast.getModelMatrices(model,1);
            
            % As we are dealing with uncertainty in the factors we need
            % to change the starting values accordingly
            kk             = kk + 1;
            mm             = draws*(kk-1);
            indK           = 1+mm:draws+mm;
            factorD        = factorDraws(:,:,ii);
            Y(indF,1,indK) = factorD(:,:,ones(1,draws));
            
            % Make draws from the distributions of the exogenous and the shocks
            y0                        = Y(:,1,1+mm); % Initial condition for forecast
            [E(:,:,indK),X(:,:,indK)] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,[],[],vcv,nSteps,draws,restrictions,struct(),inputs,options);
            
            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            for qq = indK
                Y(:,:,qq) = nb_computeForecast(A,B,C,Y(:,:,qq),X(:,:,qq),E(:,:,qq));
            end
            
            if strcmpi(model.class,'nb_fm')
                indF = strncmpi(model.exo,'Factor',6);
                F    = X(indF,:,:);
                Fac  = [nan(size(F,1),1,size(F,3)),F];
            elseif strcmpi(model.class,'nb_favar')
                numDep = length(options.dependent) + length(options.factors);
                Fac    = Y(1:numDep,:,indK);
            else
                Fac = Y(indF2,:,indK);
            end
            
            if ~isempty(inputs.observables)    
            
                % Shrink to the observables of interest
                [~,ind] = ismember(inputs.observables,model.observables);
                F       = modelDraw.F(ind,:);
                G       = modelDraw.G(ind,:);
                R       = modelDraw.R(ind,ind);
                U       = nb_mvnrand(nSteps+1,draws,0,R);
                rr      = 1;
                for qq = indK
                    Z(:,:,qq) = F*const + G*Fac(:,:,rr); % Observation equation
                end
                Z(:,:,indK) = Z(:,:,indK) + permute(U,[2,1,3]);

            end
            
            % Report current estimate in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end

                if rem(kk,note) == 0
                    h.status2 = kk;
                    h.text2   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries using bootstrap...'];
                end
            end

        end
        
        % Delete the waitbar.
        if ~inputs.parallel
            deleteSecond(h);
        end
        
    end
    
    if strcmpi(model.class,'nb_fm')
        numDep = length(options.dependent);
    else
        numDep = length(options.dependent) + length(options.factors);
    end
    
    % Return the variables of interest
    Y      = [Y(1:numDep,:,:);Z];
    XE     = [permute(X,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
      
end
