function [Y,XE,solution] = densityBootstrap(y0,restrictions,model,options,results,nSteps,iter,inputs,solution)
% Syntax:
%
% [Y,XE,solution] = nb_forecast.densityBootstrap(y0,restrictions,...
%                       model,options,results,nSteps,iter,inputs,solution)
%
% Description:
%
% Produce density forecast of a model using bootstrap.
%
% This function does not handle Markov switching models!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(model.class,'nb_sa')
        [Y,XE] = nb_forecast.densityBootstrapStepAheadModel(restrictions,model,options,results,nSteps,iter,inputs);
        return
    end
    
    if iscell(model.A)
        error([mfilename ':: The bootstrap methods are not made for Markov switching models.'])
    end

    % Only allow one identification per draws?
    if isfield(model,'identification')
        model.identification.draws = 1;
    end

    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    method         = inputs.method;
    try options    = options(iter); catch; end %#ok<CTCH>
        
    % Then we loop through each simulated data and produce forcast based on
    % the estimation on that data
    %......................................................................
    nVars = size(y0,1);
    Y     = nan(nVars,nSteps + 1,parameterDraws*draws);
    if options.recursive_estim 
        if parameterDraws == 1
            func = str2func([model.class, '.solveRecursive']);
        else
            func = str2func([model.class, '.solveNormal']);
        end
    else
        func = str2func([model.class, '.solveNormal']);
    end
    
    forecastOrKalman = false;
    if parameterDraws == 1 % Only residual uncertainty
        
        if restrictions.type ~= 3 || ~restrictions.softConditioning
            % No identification even for VARs when not conditional 
            % forecast!
            model = func(results,options); 
        end
        
        % Get model solution
        [A,B,C,vcv,~] = nb_forecast.getModelMatrices(model,iter);

        % Make draws from the distributions of the exogenous and the shocks
        [E,X,~,solution] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,[],[],vcv,nSteps,draws,restrictions,solution,inputs,options);
        
        % If we are dealing with missing observation we need to draw
        % nowcast as well
        if isempty(inputs.missing)
            Y(:,1,:) = y0(:,:,ones(1,draws));
        else
            if strcmpi(options.missingMethod,'forecast')
                forecastOrKalman = true;
                Ynow             = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);
                Y(:,1,:)         = Ynow(:,end,:); 
            else
                Y(:,1,:) = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);
            end
        end
        
        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        for jj = 1:draws
            Y(:,:,jj) = nb_computeForecast(A,B,C,Y(:,:,jj),X(:,:,jj),E(:,:,jj));
        end
        
        % Append contribution of exogenous variables when dealing with
        % ARIMA models
        if strcmpi(model.class,'nb_arima')
            [Y(1,2:end,:),Z] = nb_forecast.addZContribution(Y(1,2:end,:),model,options,restrictions,inputs,draws,iter);
        end
        
    else % Parameter uncertainty
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs);
        
        % Bootstrap coefficients
        if isfield(options,'missingData')
            bootstrapFunc = str2func('nb_missingEstimator.bootstrapModel');
        else
            bootstrapFunc = str2func([options.estimator '.bootstrapModel']);
        end
        [betaD,sigmaD,estOpt] = bootstrapFunc(model,options,results,method,parameterDraws,iter);
        
        % Preallocate
        E = nan(length(model.res),nSteps,parameterDraws*draws);
        X = nan(length(model.exo),nSteps,parameterDraws*draws);
        if strcmpi(model.class,'nb_arima')
            Z = nan(length(model.factors),nSteps,parameterDraws*draws);
        end
        
        % If we are dealing with missing observation we need to draw
        % nowcast as well (only for some methods at this point)
        if isempty(inputs.missing)
            Y(:,1,:) = y0(:,:,ones(1,parameterDraws*draws));
        else
            if strcmpi(options.missingMethod,'forecast')
                forecastOrKalman = true;
                nowcast          = max(sum(inputs.missing,1));
                Ynow             = nan(size(y0,1),nowcast,parameterDraws*draws);
            else
                Y(:,1,:) = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);
            end
        end

        kk   = 0;
        ii   = 0;
        jj   = 0;
        res  = results;
        note = nb_when2Notify(parameterDraws);
        func = str2func([model.class, '.solveNormal']);
        while kk < parameterDraws

            ii = ii + 1;
            jj = jj + 1;
            
            % Assign the results struct the posterior draw (Only using the last
            % periods estimation if recursive estimation is done)
            try
                res.beta  = betaD(:,:,ii);
                res.sigma = sigmaD(:,:,ii);
            catch %#ok<CTCH>            
                % Out of draws, so we need more!
                [betaD,sigmaD,~] = bootstrapFunc(model,options,results,method,ceil(parameterDraws*inputs.newDraws),iter);
                ii               = 0;
                continue
            end
            
            % Solve the model given the draw
            if restrictions.type == 3 || restrictions.softConditioning
                try
                    if isfield(model,'identification')
                        modelDraw = func(res,estOpt,model.identification);
                    else
                        modelDraw = func(res,estOpt);
                    end
                catch %#ok<CTCH>
                    continue
                end
            else
                % No identification even for VARs when not conditional 
                % forecast!
                modelDraw = func(res,estOpt); % No identification even for VARs! 
            end
            
            if inputs.stabilityTest
                [~,~,modulus] = nb_calcRoots(modelDraw.A);
                if any(modulus > 1)
                    continue
                end
            end 
            
            % Get model solution
            [A,B,C,vcv,~] = nb_forecast.getModelMatrices(modelDraw,1);

            % If we are dealing with missing observation we need to draw
            % nowcast as well (some method are not related to the parameter
            % draw of the given model an is already produced)
            kk  = kk + 1;
            mm  = draws*(kk-1);
            ind = 1+mm:draws+mm;
            if forecastOrKalman
                Ynow(:,:,ind) = nb_forecast.drawNowcast(y0,options,res,modelDraw,inputs,1);
                Y(:,1,ind)    = Ynow(:,end,ind);       
            end
            
            % Make draws from the distributions of the exogenous and the shocks
            [E(:,:,ind),X(:,:,ind)] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,[],[],vcv,nSteps,draws,restrictions,struct(),inputs,options);
            
            % Forecast conditional on the simulated residuals
            for qq = ind
                Y(:,:,qq) = nb_computeForecast(A,B,C,Y(:,:,qq),X(:,:,qq),E(:,:,qq));
            end
            
            % Append contribution of exogenous variables when dealing with
            % ARIMA models
            if strcmpi(model.class,'nb_arima')
                [Y(1,2:end,ind),Z(:,:,ind)] = nb_forecast.addZContribution(Y(1,2:end,ind),modelDraw,options,restrictions,inputs,draws,1);
            end
            
            % Report current estimate in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end

                if rem(kk,note) == 0
                    h.status2 = kk;
                    h.text2   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries  using bootstrap...'];
                end
            end

        end
        
        % Delete the waitbar.
        if ~inputs.parallel
            deleteSecond(h) 
        end
        
    end
    
    if forecastOrKalman
        Y = [Ynow(:,1:end-1,:),Y];
    end
    
    % Map back to correct density
    if isfield(results,'densities')
       nDep  = length(nb_forecast.getForecastVariables(options,model,inputs,'notAll'));
       [Y,X] = nb_forecast.map2Density(results.densities,Y,X,nDep);
    end
    
    if strcmpi(model.class,'nb_arima')
        XE = [permute(Z,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    else
        XE = [permute(X,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    end
      
end
