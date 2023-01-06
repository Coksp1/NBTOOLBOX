function options = forecastMethod(options)
% Syntax:
%
% options = nb_missingEstimator.forecastMethod(options)
%
% Description:
%
% Fill in for missing observations using forecast with information up 
% until time t-1, when the first missing observation is at time t.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    finish                  = options.estim_end_ind;
    tempOpt                 = options;
    tempOpt.estim_end_ind   = []; % Set it to blank to pick the last end date where the dataset is balanced.
    tempOpt.recursive_estim = false;
    tempOpt.doTests         = false;

    % Estimate model on the balanced data
    estFunc           = str2func(['nb_' options.estim_method 'Estimator.estimate']);
    [results,tempOpt] = estFunc(tempOpt);
    
    % Which observations are missing
    nSteps   = finish - tempOpt.estim_end_ind;
    missing  = options.missingData(finish-nSteps+1:finish,:);
    aMissing = all(missing,1);
    
    % Solve model
    solveFunc  = str2func([options.class '.solveNormal']);
    model      = solveFunc(results,tempOpt);
    
    % Get all variables
    allVars   = options.missingVariables;
    indRemove = cellfun(@(x)strfind(x,'_lag'),allVars,'UniformOutput',false);
    indRemove = cellfun(@isempty,indRemove);
    allVars   = allVars(indRemove);
    indExo    = ismember(allVars,options.exogenous);
    allVars   = allVars(~indExo);
    aMissing  = aMissing(~indExo);
    missing   = missing(:,~indExo);
    
    if all(aMissing)
        % All variable has missing data
        inputs               = nb_forecast.defaultInputs(true);
        inputs.output        = 'fullendo';
        inputs.varOfInterest = allVars;
        startF               = tempOpt.estim_end_ind + 1;
        fcst                 = nb_forecast(model,tempOpt,results,startF,[],nSteps,inputs,[],{},[]);
        fcstDataM            = fcst.data;
        fcstVarsM            = fcst.variables; 
    else
        
        % Find conditional information
        mSteps      = nSteps + options.nLags;
        fullVars    = [allVars,nb_cellstrlag(allVars,mSteps,'varFast')];
        missing     = flip(missing,1)';
        missing     = missing(:);
        missing     = [missing;false(length(fullVars)-size(missing,1),1)]; 
        
        % Conditional information and historical observations
        [~,locC] = ismember(allVars,options.dataVariables);
        condDB   = options.data(finish-mSteps:finish,locC);
        histDB   = transpose(vec(transpose(flip(condDB,1))));
        
        % Unconditional forecast
        nDep     = length(allVars);
        Y        = nan(nDep*options.nLags,mSteps - options.nLags + 1);
        Y(:,1)   = vec(transpose(flip(condDB(2:options.nLags + 1,1:nDep),1)))'; 
        E        = zeros(nDep,mSteps);
        [~,locX] = ismember(options.exogenous,options.dataVariables);
        X        = options.data(finish-mSteps+1:finish,locX)';
        if options.time_trend
            error([mfilename ':: Cannot set missingMethod to ''forecast'' when including a time-trend.'])
        end
        if options.constant
            X = [ones(1,mSteps); X];
        end
        uncondDB = nb_computeForecast(model.A,model.B,model.C,Y,X,E);
        uncondDB = uncondDB(1:nDep,:);
        
        % Take difference
        condDB(1:options.nLags,:)     = 0;
        condDB(options.nLags+1:end,:) = condDB(options.nLags+1:end,:) - uncondDB';
        condDB                        = transpose(vec(transpose(flip(condDB,1))));
        condDB                        = condDB(end,~missing)';
        uncondDB                      = vec(flip(uncondDB,2));
        uncondDB                      = uncondDB(missing(1:mSteps*nDep));

        % Build covariance matrix between the forecasted, conditional and
        % historical variables
        [~,c] = nb_calculateMoments(model.A,model.B,model.C,model.vcv,0,0,mSteps,'covariance');
        c     = c(1:nDep,1:nDep,:);
        R     = nb_constructStackedCorrelationMatrix(c);

        % Now we need to partition the correlation matrix
        indC  = ~missing;
        R12   = R(~indC,indC);
        R22   = R(indC,indC);

        % Adjust mean given conditional information
        numVars               = length(allVars);
        mu                    = R12/R22*condDB; 
        histDB                = histDB(1:numVars*nSteps);
        histDB(isnan(histDB)) = mu + uncondDB;
        fcstDataM             = flip(reshape(histDB,[length(allVars),nSteps])',1);
        fcstVarsM             = allVars;

    end
    
    % Assign missing observations
    [~,indV]                                  = ismember(fcstVarsM,options.dataVariables);
    options.data(finish-nSteps+1:finish,indV) = fcstDataM;
    
end
