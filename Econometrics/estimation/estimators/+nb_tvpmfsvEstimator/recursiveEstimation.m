function [results,options] = recursiveEstimation(options)
% Syntax:
%
% [results,options] = nb_tvpmfsvEstimator.recursiveEstimation(options)
%
% Description:
%
% Selects the wanted model class and recursivly estimate the model.
%
% Written by Kenneth S. Paulsen and Maximilian Schröder
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if options.smoothParam
        warning('nb_tvpmfsvEstimator:smoothParamNotSupported',...
            ['smoothParam cannot be set to true for recursive estimation. ',...
            'I.e. it is not possible to store the time-varying parameters ',...
            'in this case.'])
        options.smoothParam = false;
    end

    % When do we start?
    Tobs                    = options.estim_end_ind - options.estim_start_ind + 1; 
    numCoeff                = 40 - options.requiredDegreeOfFreedom; % This is the min number of periods accepted 
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,Tobs);

    % Create waiting bar window
    waitbar = false;
    if options.waitbar
        h = nb_estimator.openWaitbar(options,iter);
        if ~isempty(h)
            waitbar = true;       
            h.lock  = 2;
            note    = nb_when2Notify(iter);
        end
    else
        h = false;
    end
    
    if options.class == "nb_var" || options.class == "nb_mfvar"
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            options.nFactors = options.n - sum(options.indObservedOnly);
        else
            options.nFactors = options.n;
        end
    end
    
    % Get sizes of matrices
    nObs    = length(options.observables);
    nExo    = length(options.exogenous) + options.constant;
    nStates = options.nLags*options.nFactors;
    if options.class == "nb_mfvar" || options.class == "nb_var"
        % In this case the observables are stored in the smoothed.variables
        % stuct, as it is done in nb_mlEstimator and nb_bVarEstimator
        % packages
        nVars = nStates + nObs;
    else
        nVars = nStates;
    end
    
    % Preallocation
    T         = nan(nStates, nStates, iter);
    Q         = nan(options.nFactors, options.nFactors, iter);
    Z         = nan(nObs, nStates, iter);
    R         = nan(nObs, nObs, iter);
    C         = nan(nObs,nExo,iter);
    P         = nan(nStates, nStates, iter);
    vars      = nan(Tobs,nVars,iter);
    shocks_sm = nan(Tobs,options.nFactors,iter);
    ys0       = nan(1,nStates,iter); % Recursive inital value for forecasting
    errorD    = nan(Tobs,nObs,iter);
    
    % Create object for endogenous forgetting factors
    paux = struct2cell(options.prior);
    endoN = sum(cell2mat(paux(contains(fields(options.prior),'_endo_update'))));
    if endoN>0
        endoFF = NaN(Tobs,sum(contains(fields(options.prior),'_endo_update'))+1,iter);
    else
        endoFF = [];
    end
    
    if options.class == "nb_fmdyn"
        obs              = nan(Tobs,nObs,iter);
        storeObservables = true;
    else
        storeObservables = false;
    end
    
    if isfield(options,'transformation')
        if strcmpi(options.transformation,'standardize')
            nS = nObs;
        else
            nS = 0;
        end
        S = nan(nS,1,iter);
    end
    
    nExo = length(options.exogenous);
    if options.constant + options.time_trend == 0
        W = nan(Tobs,nExo,iter);
    elseif options.constant + options.time_trend == 1
        W = nan(Tobs,1 + nExo,iter);
    elseif options.constant + options.time_trend == 2
        W = nan(Tobs,2 + nExo,iter);
    end
    
    % Loop the rest
    kk        = 1;
    start_ind = options.estim_start_ind;
    results   = [];
    for tt = start:Tobs
        
        % Estimate model on this sample
        options.estim_end_ind   = start_ind + tt - 1;
        options.estim_start_ind = start_ind + ss(kk) - 1;
        [results,options]       = nb_tvpmfsvEstimator.normalEstimation(options);%,results
        
        % Assign estimation results
        C(:,:,kk) = results.C; % mean
        S(:,:,kk) = results.S; % standard deviation
        T(:,:,kk) = results.T; % beta coefficient
        Q(:,:,kk) = results.Q; % factors, covar
        Z(:,:,kk) = results.Z; % loadings
        R(:,:,kk) = results.R; % observables covar
        P(:,:,kk) = results.P; % one-step-ahead forecast error covar
        
        % Assign endogenous forgetting factors, if set
        if endoN>0
            endoFF(ss(kk):tt,:,kk) =  results.smoothed.endoFF';
        end
        
        % Assign smoothed results
        W(ss(kk):tt,:,kk)      = results.W;     % deterministic vars (constant/trend)
        vars(ss(kk):tt,:,kk)   = results.smoothed.variables.data; % data of factors
        errorD(ss(kk):tt,:,kk) = results.smoothed.errors.data;    % residuals
        ys0(:,:,kk)            = vars(tt,1:nStates,kk); % Inital value for recursive forecasting
        if options.smoothShocks == 1
            shocks_sm(ss(kk):tt,:,kk) = results.smoothed.shocks.data; % smoothed shocks
        end
        if storeObservables
            obs(ss(kk):tt,:,kk) = results.smoothed.observables.data; % data of observables
        end
        
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    options.estim_start_ind = start_ind;
    
    % Assign results
    results.C      = C;
    results.S      = S;
    results.T      = T;
    results.Q      = Q;
    results.Z      = Z;
    results.R      = R;
    results.P      = P;
    results.W      = W;
    results.ys0    = ys0;
    results.endoFF = endoFF;
    
    sDate                      = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    results.smoothed.W         = struct('data',W,'startDate',toString(sDate),'variables',{'deterministic'});
    results.smoothed.variables = struct('data',vars,'startDate',toString(sDate),'variables',{results.smoothed.variables.variables});
    results.smoothed.errors    = struct('data',errorD,'startDate',toString(sDate),'variables',{results.smoothed.errors.variables});
    if options.smoothShocks == 1
        results.smoothed.shocks = struct('data',shocks_sm,'startDate',toString(sDate),'variables',{results.smoothed.shocks.variables});
    end
    if storeObservables
        results.smoothed.observables = struct('data',obs,'startDate',toString(sDate),'variables',{results.smoothed.observables.variables});
    end
    
    % Filter info
    if ~isempty(options.rollingWindow)
        nPeriods                = options.estim_end_ind - options.estim_start_ind;
        results.filterStartDate = toString(sDate);
        results.filterEndDate   = toString(sDate + nPeriods);
    end
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end
    
end
 

