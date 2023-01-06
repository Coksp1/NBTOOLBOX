function [Y,XE] = densityBootstrapStepAheadModel(restrictions,model,options,results,nSteps,iter,inputs)
% Syntax:
%
% [Y,XE] = nb_forecast.densityBootstrapStepAheadModel(...
%               restrictions,model,options,results,nSteps,iter,inputs)
%
% Description:
%
% Produce density forecast of a step ahead model using bootstrap.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(inputs.missing)
        error([mfilename ':: Density forecast of step-ahead models that are estimated with missing '...
            'observations are not yet supported. Contact Kenneth S. Paulsen if needed.'])
    end

    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    method         = inputs.method;
    try options    = options(iter); catch; end %#ok<CTCH>

    % Get the function to use to solve the model
    if isfield(options(end),'nStep')
        modelClass = 'nb_sa';
    else
        modelClass = 'nb_singleEq';
    end
    if options.recursive_estim 
        if parameterDraws == 1
            func = str2func([modelClass, '.solveRecursive']);
        else
            func = str2func([modelClass, '.solveNormal']);
        end
    else
        func = str2func([modelClass, '.solveNormal']);
    end
    
    % Preallocate memory
    dep   = nb_forecast.getForecastVariables(options,model,inputs,'notObservables');
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
            Y(:,:,jj) = B*X(:,1,jj) + E(:,1,jj);
        end
        
    else
    
        % Bootstrap coefficients
        if isfield(options,'missingData')
            bootstrapFunc = str2func('nb_missingEstimator.bootstrapModel');
        else
            bootstrapFunc = str2func([options.estimator '.bootstrapModel']);
        end
        [betaD,sigmaD,estOpt] = bootstrapFunc(model,options,results,method,parameterDraws,iter);
        
        E = nan(nDep*leads,1,parameterDraws*draws);
        X = nan(length(model.exo),leads,parameterDraws*draws);
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs);
        
        kk   = 0;
        ii   = 0;
        jj   = 0;
        note = nb_when2Notify(parameterDraws);
        while kk < parameterDraws

            ii = ii + 1;
            jj = jj + 1;
            
            % Assign the data field one simulated sequence of artificial data 
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
            func      = str2func([modelClass, '.solveNormal']);
            modelDraw = func(res,estOpt); % No identification even for VARs! 
            
            % Calculate density forecast
            B   = modelDraw.B;
            vcv = modelDraw.vcv;

            % Make draws from the distributions of the exogenous and the shocks
            kk         = kk + 1;
            mm         = draws*(kk-1);
            ind        = 1+mm:draws+mm;
            index      = restrictions.index;
            Xt         = restrictions.X(:,:,index)';
            X(:,:,ind) = Xt(:,:,ones(1,draws));
            E(:,:,ind) = nb_forecast.multvnrnd(vcv,1,draws);
            
            % Forecast conditional on the simulated residuals
            for qq = ind
                Y(:,:,qq) = B*X(:,1,qq) + E(:,1,qq);
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
            deleteSecond(h);
        end
        
    end
    
    % Then we need to reorder stuff, as we here are not forcasting h step 
    % ahead using the normal syntax
    Y  = reshape(Y,[leads,nDep,parameterDraws*draws]);
    Y  = [nan(1,nDep,size(Y,3));Y(1:nSteps,:,:)];
    Y  = permute(Y,[2,1,3]);
    E  = reshape(E,[leads,nDep,parameterDraws*draws]);
    XE = [permute(X,[2,1,3]),E(1:nSteps,:,:)];
                 
end
