function options = kalmanMethod(options)
% Syntax:
%
% options = nb_missingEstimator.kalmanMethod(options)
%
% Description:
%
% Fill in for missing observations a Kalman filter.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~any(strcmpi(options.class,{'nb_var','nb_pitvar'}))
        error([mfilename ':: Setting missingMethod to ''kalmanFilter'' is only possible for nb_var and nb_pitvar objects.'])
    end
    finish                  = options.estim_end_ind;
    start                   = options.estim_start_ind;
    tempOpt                 = options;
    tempOpt.estim_end_ind   = []; % Set it to blank to pick the last end date where the dataset is balanced.
    tempOpt.recursive_estim = false;
    tempOpt.doTests         = false;

    % Find start date of balanced data
    dep        = [options.dependent, options.block_exogenous];
    exo        = options.exogenous;
    allVars    = [dep,exo];
    [~,indAll] = ismember(allVars,options.dataVariables);
    if isempty(tempOpt.estim_start_ind)
        startInd = 1;
    else
        startInd = tempOpt.estim_start_ind;
    end
    XAll       = tempOpt.data(startInd:end,indAll);
    anyMissing = any(isnan(XAll),2);
    endInd     = find(~anyMissing,1,'last');
    startBal   = find(anyMissing(1:endInd),1,'last');
    if isempty(startBal)
        startBal = 0;
    end
    tempOpt.estim_start_ind = startBal + options.nLags + 1;
    
    % Estimate model on the balanced data
    estFunc           = str2func(['nb_' options.estim_method 'Estimator.estimate']);
    [results,tempOpt] = estFunc(tempOpt);
    
    % Solve model
    solveFunc  = str2func([options.class '.solveNormal']);
    model      = solveFunc(results,tempOpt);
    
    % Data to filter
    [~,indObs]  = ismember(dep,options.dataVariables);
    yT          = tempOpt.data(:,indObs)';
    nDep        = size(yT,1);
    [~,indXObs] = ismember(options.exogenous,options.dataVariables);
    XT          = tempOpt.data(:,indXObs)';
    if isempty(start)
        if isempty(XT)
            start = find(~all(isnan(yT),1),1);
        else
            exoMissing = any(isnan(XT),1);
            endInd     = find(~exoMissing,1,'last');
            startExo   = find(exoMissing(1:endInd),1,'last');
            if isempty(startExo)
                startExo = 1;
            else
                startExo = startExo + 1;
            end
            start = max(find(~all(isnan(yT),1),1),startExo);
        end
        if isempty(start)
           start = 1; 
        end
    end
    yT = yT(:,start:finish);
    XT = XT(:,start:finish);
    if options.constant
        XT = [ones(1,size(XT,2)); XT];
    end
    if any(any(isnan(XT)))
        
        exo = options.exogenous;
        if options.constant
            exo = ['constant',exo];
        end
        ind = any(isnan(XT),2);
        error(['Cannot have any missing observations on an exogneous variable ',...
               'when setting missingMethod to ''kalmanFilter''. This is the case ',...
               'for the following variables; ' toString(exo(ind))])
    end
    
    % Do the filtering
    statSpaceHandle = @()nb_missingEstimator.getStateSpace(options,model);
    [~,ys]          = nb_kalmansmoother_missing(statSpaceHandle,yT,XT);
    
    % Assign missing observations
    options.data(start:finish,indObs) = ys(:,1:nDep);

end
