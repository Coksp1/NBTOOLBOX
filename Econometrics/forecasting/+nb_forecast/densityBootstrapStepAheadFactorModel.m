function [Y,XE] = densityBootstrapStepAheadFactorModel(y0,restrictions,model,options,results,nSteps,iter,inputs)
% Syntax:
%
% [Y,XE] = nb_forecast.densityBootstrapStepAheadFactorModel(y0,...
%               restrictions,model,options,results,iter,inputs)
%
% Description:
%
% Produce density forecast of a step ahead factor model using bootstrap.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    
    % Get the variables to forecast
    dep = nb_forecast.getForecastVariables(options,model,inputs,'notObservables');
    
    % Preallocate memory
    nDep  = length(dep);
    leads = size(model.B,1)/nDep;
    Y     = nan(nDep*leads,1,draws*parameterDraws);
    
    % Produce forecast
    %----------------------------------------------------------------------
    if parameterDraws == 1 % Only residual uncertainty
        
        model = func(results,options);
        
        % Calculate density forecast
        B   = model.B(:,:,iter);
        vcv = model.vcv(:,:,iter);
        
        % Make draws from the distributions of the exogenous and the shocks
        index = restrictions.index;
        X     = restrictions.X(:,:,index)';
        X     = X(:,:,ones(1,draws));
        E     = nb_forecast.multvnrnd(vcv,1,draws);
        
        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        for jj = 1:draws
            Y(:,:,jj) = B*X(:,1,jj) + E(:,:,jj);
        end
        
    else
    
        % Then we loop through each parameter set
        %......................................................................
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs);
        
        % Make the parameter draws
        %..........................
        options.stdType   = method;
        options.stdReplic = parameterDraws;
        [betaDraws,lambdaDraws,sigmaDraws,~,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,iter);   

        % Get the initial values of the drawn factors
        factorDraws = permute(factorDraws(end,:,:),[2,1,3]);
        
        % Loop through the parameter draws and produce density forecast
        E    = nan(nDep*leads,1,parameterDraws*draws);
        X    = nan(length(model.exo),nSteps,parameterDraws*draws);
        res  = results;
        kk   = 0;
        indF = ~cellfun(@isempty,regexp(model.exo,'Factor[0-9]*'));
        note = nb_when2Notify(parameterDraws);
        for ii = 1:parameterDraws

            res.beta   = betaDraws(:,:,ii);
            res.lambda = lambdaDraws(:,:,ii);
            res.sigma  = sigmaDraws(:,:,ii);
            
            % Solve the model given the posterior draw
            func      = str2func([model.class, '.solveNormal']);
            modelDraw = func(res,options);

            % Calculate density forecast
            B   = modelDraw.B;
            vcv = modelDraw.vcv;
            
            % As we are dealing with uncertainty in the factors we need
            % to change the starting values accordingly
            F = factorDraws(:,:,ii);
            
            % Make draws from the distributions of the exogenous and the shocks
            kk         = kk + 1;
            mm         = draws*(kk-1);
            ind        = 1+mm:draws+mm;
            index      = restrictions.index;
            Xt         = restrictions.X(:,:,index)';
            X(:,:,ind) = Xt(:,:,ones(1,draws));
            E(:,:,ind) = nb_forecast.multvnrnd(vcv,1,draws);
          
            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            X(indF,1,ind) = F(:,:,ones(1,draws));
            for jj = 1+mm:draws+mm       
                Y(:,:,jj) = B*X(:,1,jj) + E(:,:,jj);
            end
            
            % Report current estimate in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end

                if rem(ii,note) == 0
                    h.status2 = ii;
                    h.text2   = ['Finished with ' int2str(ii) ' draws using bootstrap...'];
                end
            end

        end
        
        % Delete the waitbar.
        if ~inputs.parallel
            deleteSecond(h);
        end
        
    end
    
    % Then we need to reorder stuff, as we here are not forcasting h step 
    % ahead using the normal syntax
    Y  = reshape(Y,[nDep,leads,draws*parameterDraws]);
    Y  = Y(:,1:nSteps,:);
    Y  = [nan(size(Y,1),1,size(Y,3)),Y];
    E  = reshape(E,[nDep,leads,draws*parameterDraws]);
    XE = [permute(X,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
                 
end
