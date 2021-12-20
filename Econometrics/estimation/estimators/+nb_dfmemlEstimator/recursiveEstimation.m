function [results,options] = recursiveEstimation(options)
% Syntax:
%
% [results,options] = nb_dfmemlEstimator.recursiveEstimation(options)
%
% Description:
%
% Selects the wanted model class and recursivly estimate the model.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get coefficients
    nCoeff = nb_dfmemlEstimator.getNumberOfCoeff(options);

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
    
    % Get sizes of matrices
    nObs = length(options.observables);
    nExo = length(options.exogenous) + options.time_trend + options.constant;
    if options.mixedFrequency
        nLow  = options.nLow;
        mLags = max(options.nLags,5);
    else
        nLow  = 0;
        mLags = options.nLags;
    end
    nStates = options.nFactors*mLags + nLow*4;
    if options.nLagsIdiosyncratic
        nShocks = nObs + options.nFactors;
        nStates = nStates + nObs;
    else
        nShocks = options.nFactors;
    end
    
    % Preallocation
    T  = nan(nStates,nStates,iter);
    Z  = nan(nObs,nStates,iter);
    BQ = nan(nStates,nStates);
    R  = nan(nObs,nObs,iter);
    C  = nan(nObs,nExo,iter);
    if strcmpi(options.transformation,'standardize')
        nS = nObs;
    else
        nS = 0;
    end
    S        = nan(nS,1,iter);
    beta     = nan(nCoeff,1,iter);
    vars     = nan(Tobs,nStates,iter);
    obs      = nan(Tobs,nObs,iter);
    ys0      = nan(1,nStates,iter); % Recursive inital value for forecasting
    shocks   = nan(Tobs,nShocks,iter);
    errorD   = nan(Tobs,nObs,iter);
    lik      = nan(1,iter);
    
    % Loop the rest
    kk        = 1;
    start_ind = options.estim_start_ind;
    results   = [];
    for tt = start:Tobs
        
        % Estimate model on this sample
        options.estim_end_ind   = start_ind + tt - 1;
        options.estim_start_ind = start_ind + ss(kk) - 1;
        [results,options]       = nb_dfmemlEstimator.normalEstimation(options);%,results
        
        % Assign estimation results
        T(:,:,kk)    = results.T;
        Z(:,:,kk)    = results.Z;
        BQ(:,:,kk)   = results.BQ;
        R(:,:,kk)    = results.R;
        C(:,:,kk)    = results.C;
        S(:,:,kk)    = results.S;
        beta(:,:,kk) = results.beta;
        lik(kk)      = results.likelihood;
        
        % Assign smoothed results
        vars(ss(kk):tt,:,kk)   = results.smoothed.variables.data;
        obs(ss(kk):tt,:,kk)    = results.smoothed.observables.data; % data of observables
        shocks(ss(kk):tt,:,kk) = results.smoothed.shocks.data;
        errorD(ss(kk):tt,:,kk) = results.smoothed.errors.data;
        ys0(1,:,kk)            = vars(tt,:,kk); % Inital value for recursive forecasting
        
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    options.estim_start_ind = start_ind;
    
    % Assign results
    results.T          = T;
    results.Z          = Z;
    results.BQ         = BQ;
    results.C          = C;
    results.S          = S;
    results.beta       = beta;
    results.likelihood = lik;
    results.ys0        = ys0;
    
    sDate                        = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    results.smoothed.variables   = struct('data',vars,'startDate',toString(sDate),'variables',{results.smoothed.variables.variables});
    results.smoothed.shocks      = struct('data',shocks,'startDate',toString(sDate),'variables',{results.smoothed.shocks.variables});
    results.smoothed.errors      = struct('data',errorD,'startDate',toString(sDate),'variables',{results.smoothed.errors.variables});
    results.smoothed.observables = struct('data',obs,'startDate',toString(sDate),'variables',{results.smoothed.observables.variables});
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end
    
end
