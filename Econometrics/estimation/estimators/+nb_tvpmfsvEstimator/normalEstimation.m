function [results,options] = normalEstimation(options,results)
% Syntax:
%
% [res,options] = nb_tvpmfsvEstimator.normalEstimation(options,results)
%
% Description:
%
% Selects the wanted model class and estimate the model.
%
% Inputs:
%
% - options : A struct on the format returned by
%             nb_tvpmfsvEstimator.template.
%
% - results : A struct with initial conditions for EML iterations. Can be
%             used for recursive estimation. If empty or not provided this 
%             struct is provided by nb_tvpmfsvEstimator.initialize
%
% Written by Kenneth S. Paulsen and Maximilian Schröder
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        results = [];
    end

    % Sample
    startInd = options.estim_start_ind;
    endInd   = options.estim_end_ind;
    
    % Use last valid observations
    [~,indX] = ismember(options.observables,options.dataVariables);
    X        = options.data(startInd:endInd,indX);
    [~,indW] = ismember(options.exogenous,options.dataVariables);
    
    % Set observations to nan
    if ~nb_isempty(options.set2nan)
        startD = nb_date.date2freq(options.dataStartDate) + (startInd - 1);
        X      = nb_estimator.set2nan(X,startD,options.observables,options.set2nan);
    end
    
    % Skip treatment of exogenous variables, if none are in the model
    W = options.data(startInd:endInd,indW);
    W = addDeterministic(options,W);
    if ~isempty(options.exogenous) || options.constant
        [Xhat,C] = cleanGivenExo(options,X,W);
    else
        C    = [];
        Xhat = X;
    end
    
    % apply transformations to X
    if isfield(options,'transformation')
        [Xhat,S] = applyTransformation(options,Xhat);
    end
     
    if options.class == "nb_var" || options.class == "nb_mfvar"
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            options.nFactors = options.n - sum(options.indObservedOnly);
        else
            options.nFactors = options.n;
        end
    end
    
    % Get prior
    priors = nb_tvpmfsvEstimator.getPriors(options);
    
    % Estimate factors using PCA. Missing values in the original dataset 
    % are handled using an iterative expectation-maximization (EM) 
    % algorithm.
    if strcmpi(options.class,'nb_var') || strcmpi(options.class,'nb_mfvar')
        % in the VAR case, the factors are set equal to the variables
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            F = nb_estimator.fillInForMissing(Xhat(:,~options.indObservedOnly));
        else
            F = nb_estimator.fillInForMissing(Xhat);
        end
    else
        % draw initial factors with PCA
        F = nb_pca(Xhat,options.nFactors,'svd','unbalanced',true);
        if any(isnan(F))
            F = nb_estimator.fillInForMissing(F);
        end
    end
    
    % Run the Kalman filters for the parameter estimation 
    [lambda_sm,beta_sm,beta_t_sm,Q_t_sm,V_t_sm,endo_ff] = ...
        nb_tvpmfsvEstimator.f_KFS_params(options,priors,F,Xhat);
        
    % Run the Kalman filters for the factor estimation
    [FSM,H_t,vs,Ps_t] = nb_tvpmfsvEstimator.f_KFS_fac(options,priors,Xhat,...
        lambda_sm,beta_sm,Q_t_sm,V_t_sm);

    % Back out the smoothed factor state equation shocks
    if options.smoothShocks
        eps_f_sm = nb_tvpmfsvEstimator.f_smoothed_fac_shocks(priors, FSM, beta_sm);
    end
    
    % Explained variance
    if not(strcmpi(options.class,'nb_var') || strcmpi(options.class,'nb_mfvar')) ...
            && options.doTests
        
        fVar = nan(1,size(F,2));
        for ii = 1:size(F,2)
            XPred = nan(size(Xhat,2),size(Xhat,1)); 
            for tt = 1:size(XPred,2)
                for vv = 1:size(XPred,1)
                    XPred(vv,tt) = H_t(vv,ii,tt)*FSM(ii,tt);
                end
            end
            fVar(ii) = sum(diag(XPred*XPred'/size(XPred,2)));
        end
        
        isNaN = isnan(Xhat);
        if any(isNaN(:))
            for tt = 1:size(Xhat,1)
                for vv = 1:size(Xhat,2)
                    if isNaN(tt,vv)
                        Xhat(tt,vv) = H_t(vv,:,tt)*FSM(:,tt);
                    end
                end
            end
        end
        totVar       = sum(diag(Xhat'*Xhat/size(Xhat,1)));
        results.expl = fVar./totVar*100;
    end
    
    % Store filtering results in the way we do it elsewhere
    sDate                      = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    [stateNames,resNames]      = nb_tvpmfsvEstimator.getStateNames(options);
    results.smoothed.variables = struct('data',FSM','startDate',toString(sDate),'variables',{stateNames});
    errorNames                 = strcat('V_',options.observables);
    results.smoothed.errors    = struct('data',vs','startDate',toString(sDate),'variables',{errorNames});
    results.smoothed.lambda    = struct('data',H_t(options.reorderLoc,:,:),'startDate',toString(sDate),'variables',{stateNames},'observables',{options.observablesOrig});
    if options.smoothParam
        results.smoothed.beta = struct('data',beta_t_sm,'startDate',toString(sDate),'parameters',{stateNames},'equations',{stateNames(1:options.nFactors)});
        results.smoothed.V    = struct('data',V_t_sm,'startDate',toString(sDate),'variables',{options.observablesOrig});
        results.smoothed.Q    = struct('data',Q_t_sm,'startDate',toString(sDate),'variables',{resNames});
    end
    if options.smoothShocks
        results.smoothed.shocks = struct('data',eps_f_sm','startDate',toString(sDate),'variables',{resNames});
    end
    
    % store endogenous ff, if setting turned on
    paux = struct2cell(priors);
    if sum(cell2mat(paux(contains(fields(priors),'_endo_update'))))>0
       results.smoothed.endoFF = endo_ff; 
    else
       results.smoothed.endoFF = [];
    end
    
    % Store exogenous, if exogenous variables in the model
    results.W = W;
    results.C = C'; 
    
    % store transformations, if variables transformes
    if isfield(options,'transformation')
        results.S = S;
    else
        results.S = [];
    end 
    
    results.T = beta_sm(:,:,end);
    results.Q = Q_t_sm(:,:,end);
    results.Z = H_t(:,:,end);
    results.R = V_t_sm(:,:,end);
    results.P = Ps_t(:,:,end);
    
    % Construct the vector of estimated parameters
    results = reorderObservables(options,results);
    
    % Get the missing values of all the observables
    if options.class == "nb_fmdyn"
        observables                  = double(nb_tvpmfsvEstimator.getObservables(results,options));
        results.smoothed.observables = struct('data',observables,'startDate',toString(sDate),'variables',{options.observablesOrig});
        if ~options.smoothParam
            results.smoothed = rmfield(results.smoothed,'lambda');
        end
    elseif options.class == "nb_mfvar" || options.class == "nb_var"
        % Add the values of the original transformation
        observables                          = double(nb_tvpmfsvEstimator.getObservables(results,options));
        results.smoothed.variables.data      = [results.smoothed.variables.data, observables];
        results.smoothed.variables.variables = [results.smoothed.variables.variables, options.observablesOrig];  
    end
    
    % Filter info
    nPeriods                = options.estim_end_ind - options.estim_start_ind;
    results.filterStartDate = toString(sDate);
    results.filterEndDate   = toString(sDate + nPeriods);
    results.realTime        = false;
    
end

%==========================================================================
function W = addDeterministic(options,W)

    T = size(W,1);
    if options.time_trend
        tt = 1:T;
        W  = [tt,W];
    end
    if options.constant
       W = [ones(T,1),W]; 
    end

end

%==========================================================================
function [Xhat,C]  = cleanGivenExo(options,X,W)
% Remove the contribution of the exogenous variables, may be constant,
% time-trend or any user defined variable

    if options.constant && size(W,2) == 1
        % Estimate contant term using mean of X
        C    = mean(X,'omitnan');
        Xhat = bsxfun(@minus,X,C);
        return
    end
    
    % Estimate the impact of exogenous variables using OLS on the
    % stripped data
    C = zeros(size(W,2),size(X,2));
    if ~isempty(options.exogenous)
       
        for ii = 1:size(X,2)
            
            isNaN = any(isnan(X(:,ii)),2) | any(isnan(W),2);
            Xest  = X(~isNaN,ii);
            West  = W(~isNaN,:);
            if options.removeZeroRegressors
                indKeep = ~all(West == 0,1);
            else
                indKeep = true(1,size(W,2));
            end
            if any(indKeep)
                West          = West(:,indKeep);
                C(indKeep,ii) = nb_ols(Xest,West);
            end
        end
        Xhat = X - W*C;
    else
        Xhat = X;
    end
end

%==========================================================================
function [Xhat,S]  = applyTransformation(options,Xhat)
% Dp we want to standardize the observables?

    switch lower(options.transformation)
        case 'standardize'
            S    = std(Xhat,'omitnan');
            Xhat = bsxfun(@rdivide,Xhat,S);
            S    = S';
        otherwise 
            S = [];
    end

end

%==========================================================================
function results = reorderObservables(options,results)
% Reorder so that the results keep the ordering of observables from the
% user side, i.e. the observables with low frequencies not necessary
% ordered last

    if ~isempty(options.exogenous) || options.constant
        results.C = results.C(options.reorderLoc,:);
    end
    
    results.Z = results.Z(options.reorderLoc,:);
    if ~isempty(results.S)
        results.S = results.S(options.reorderLoc,:);
    end
    
end
