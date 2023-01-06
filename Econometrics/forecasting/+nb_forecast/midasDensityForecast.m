function [fData,evalFcst] = midasDensityForecast(y0,restrictions,model,options,results,nSteps,iter,actual,inputs)
% Syntax:
%
% [fData,evalFcst] = nb_forecast.midasDensityForecast(y0,restrictions,...
%                       model,options,results,nSteps,iter,actual,inputs)
%
% Description:
%
% Produce density forecast of MIDAS models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    method         = inputs.method;
    
    % Then we loop through each simulated data and produce forcast based on
    % the estimation on that data
    %......................................................................
    nVars = size(y0,1);
    Y     = nan(nVars,nSteps + 1,parameterDraws*draws);
    if parameterDraws == 1 % Only residual uncertainty
        
        % Get model solution
        modelIter = nb_forecast.getModelMatrices(model,iter,false,options,nSteps);

        % Make draws from the distributions of the exogenous and the shocks
        E = nb_forecast.multvnrnd(modelIter.vcv,1,draws);
        E = permute(E,[2,1,3]);
        X = permute(restrictions.X(restrictions.index,:,:),[2,1,3]);
        
        % Initial conditions
        Y(:,1,:) = y0(:,:,ones(1,draws));

        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        for jj = 1:draws
            Y(:,:,jj) = nb_computeMidasForecast(modelIter.A,modelIter.B,Y(:,:,jj),X,E(:,:,jj));
        end
        
    else
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        if ~inputs.parallel
            if isfield(inputs,'waitbar')
               h = inputs.waitbar;
            else
                if isfield(inputs,'index')
                    figureName = ['Forecast for Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)];
                else
                    figureName = 'Forecast';
                end
                h = nb_waitbar5([],figureName,true);
                inputs.waitbar = h;
            end
            h.text2          = 'Drawing parameters (this could take some time)...';  
            h.maxIterations2 = parameterDraws;
        else
            h = [];
        end
        
        % Bootstrap coefficients
        [betaD,sigmaD,estOpt] = nb_midasEstimator.bootstrapModel(model,options,results,method,parameterDraws,iter,false);
        
        % Preallocate
        X = permute(restrictions.X(restrictions.index,:,:),[2,1,3]);
        
        % Initial conditions
        Y(:,1,:) = y0(:,:,ones(1,parameterDraws*draws));

        kk   = 0;
        ii   = 0;
        jj   = 0;
        res  = results;
        note = nb_when2Notify(parameterDraws);
        func = str2func([model.class, '.solveNormal']);
        while kk < parameterDraws

            ii  = ii + 1;
            jj  = jj + 1;
            kk  = kk + 1;
            mm  = draws*(kk-1);
            ind = 1+mm:draws+mm;
            
            % Assign the results struct the posterior draw (Only using the last
            % periods estimation if recursive estimation is done)
            try
                res.beta  = betaD(:,:,ii);
                res.sigma = sigmaD(:,:,ii);
            catch %#ok<CTCH>            
                % Out of draws, so we need more!
                [betaD,sigmaD] = nb_midasEstimator.bootstrapModel(model,options,results,method,ceil(parameterDraws*inputs.newDraws),iter,true);
                ii             = 0;
                continue
            end

            % Solve model
            modelDraw = func(res,estOpt);           
            if inputs.stabilityTest
                [~,~,modulus] = nb_calcRoots(modelDraw.A);
                if any(modulus > 1)
                    continue
                end
            end 
            
            % Get model solution
            A   = modelDraw.A;
            B   = modelDraw.B;
            vcv = modelDraw.vcv;

            % Make draws from the distributions of the exogenous and the shocks
            ET = permute(nb_forecast.multvnrnd(vcv,1,draws),[2,1,3]);

            % Forecast conditional on the simulated residuals
            dd = 1;
            for qq = ind
                Y(:,:,qq) = nb_computeMidasForecast(A,B,Y(:,:,qq),X,ET(:,:,dd));
                dd        = dd + 1;
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
    
    % Permute and strip forecast
    Y = Y(:,2:end,:);
    Y = permute(Y,[2,1,3]);
    
    % Get the forecast variable
    dep = nb_forecast.getForecastVariables(options,model,inputs,'pointForecast');
    
    % Create reported variables
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            % Here we need to transform the historical data to the
            % frequency of the dependent variable. Here we remove all data
            % before the options.start_low, which means we must use
            % restrictions.index instead of restrictions.start 
            optLow  = nb_forecast.midasPrepareForReporting(options);
            [Y,dep] = nb_forecast.createReportedVariables(optLow,inputs,Y,dep,restrictions.index,iter);
        end
    end
    
    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        [ind,indV] = ismember(vars,dep);
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = dep(indV);
    end
    
    % Evalaute and report forecast
    [fData,evalFcst] = nb_forecast.evaluateDensityForecast(Y,actual,dep,model,options,inputs);
         
end
