function [results,options] = normalEstimation(options,results)
% Syntax:
%
% [res,options] = nb_dfmemlEstimator.normalEstimation(options,results)
%
% Description:
%
% Selects the wanted model class and estimate the model.
%
% Inputs:
%
% - options : A struct on the format returned by
%             nb_dfmemlEstimator.template.
%
% - results : A struct with initial conditions for EML iterations. Can be
%             used for recursive estimation. If empty or not provided this 
%             struct is provided by nb_dfmemlEstimator.initialize
%
% Written by Kenneth S. Paulsen
    
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
    W        = options.data(startInd:endInd,indW);
    W        = addDeterministic(options,W);
    
    % Set observations to nan
    if ~nb_isempty(options.set2nan)
        startD = nb_date.date2freq(options.dataStartDate) + (startInd - 1);
        X      = nb_estimator.set2nan(X,startD,options.observables,options.set2nan);
    end
    
    % Clean data of exogenous part.
    [Xhat,C] = cleanGivenExo(options,X,W);
    [Xhat,S] = applyTransformation(options,Xhat);
    
    % Initialization coefficient matrices
    if isempty(results)
        results = nb_dfmemlEstimator.initialize(options,Xhat);
    end
    results.C = C';
    results.S = S;
    
    % Expected maximum likelihood estimation
    iter      = 0;
    converged = false;
    tol       = options.fix_point_TolFun;
    if options.fix_point_verbose
        format = 'Iter: %5d  f(x): %10.4f   %%-change: %2.2f \n';
    end
    prevLik = inf;
    while iter < options.fix_point_maxiter && ~converged
        oldLogLik = results.likelihood;
        results   = nb_dfmemlEstimator.emlIteration(options,results,Xhat);
        iter      = iter + 1;
        if iter > 1
            converged = nb_dfmemlEstimator.checkConvergence(results,oldLogLik,tol);
            if options.fix_point_verbose
                if rem(iter,10) == 0
                    change = 100*(results.likelihood - prevLik)/prevLik;
                    fprintf(format,[iter,results.likelihood,change])
                    prevLik = results.likelihood;
                end
            end
        else
            prevLik = results.likelihood;
        end
    end
    
    % Print final likelihood
    if options.fix_point_verbose
        format = 'Final: %4d  f(x): %10.4f \n';
        fprintf(format,[iter,results.likelihood])
    end

    % Final run of the kalman smoother
    [alpha0,P0,Pinf0] = nb_dfmemlEstimator.intiKF(results);
    if isempty(Pinf0)
        [~,~,alpha,e,lik,Ps] = nb_kalmanSmootherAndLikelihood(results.Z,results.R,results.T,results.BQ,alpha0,P0,Xhat',...
                                    options.kf_kalmanTol,options.kf_presample);
    else
        [~,~,alpha,e,lik,Ps] = nb_kalmanSmootherAndLikelihoodUnivariate(results.Z,results.R,results.T,results.BQ,alpha0,...
                                    P0,Pinf0,Xhat',options.kf_kalmanTol,options.kf_presample);
    end
    
    % Explained variance
    if ~options.mixedFrequency && options.doTests
        F    = alpha(1:options.nFactors,:);
        H    = results.Z(:,1:options.nFactors);
        fVar = nan(1,size(F,1));
        for ii = 1:size(F,1)
            XPred = nan(size(Xhat,2),size(Xhat,1)); 
            for tt = 1:size(XPred,2)
                for vv = 1:size(XPred,1)
                    XPred(vv,tt) = H(vv,ii)*F(ii,tt);
                end
            end
            fVar(ii) = sum(diag(XPred*XPred'/size(XPred,2)));
        end

        isNaN = isnan(Xhat);
        if any(isNaN(:))
            for tt = 1:size(Xhat,1)
                for vv = 1:size(Xhat,2)
                    if isNaN(tt,vv)
                        Xhat(tt,vv) = results.Z(vv,:)*alpha(:,tt);
                    end
                end
            end
        end
        totVar       = sum(diag(Xhat'*Xhat/size(Xhat,1)));
        results.expl = fVar./totVar*100;
    end
    
    % Get estimate of the variance of factors 
    T    = size(Ps,3);
    nFac = options.nFactors;
    indF = 1:nFac;
    varF = nan(T,nFac);
    for tt = 1:T
        varF(tt,:) = diag(Ps(indF,indF,tt)); % diag(P t|t)
    end
                        
    % Store filtering results in the way we do it elsewhere
    sDate                        = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    [stateNames,resNames]        = nb_dfmemlEstimator.getStateNames(options);
    results.smoothed.variables   = struct('data',alpha','startDate',toString(sDate),'variables',{stateNames});
    results.smoothed.shocks      = struct('data',e','startDate',toString(sDate),'variables',{resNames});
    results.smoothed.variances   = struct('data',varF,'startDate',toString(sDate),'variables',{stateNames(1:nFac)});
    results.likelihood           = lik;  
    results.W                    = W;
    
    % Measurement errors
    if options.nLagsIdiosyncratic
        vs    = Xhat' - results.Z*alpha;
        i     = isnan(vs);
        vs(i) = 0;
        vs    = vs';
    else
        vs = zeros(size(Xhat));
    end
    errorNames              = strcat('V_',options.observables);
    results.smoothed.errors = struct('data',vs,'startDate',toString(sDate),'variables',{errorNames});
    
    % Get the missing values of all the observables
    observables                  = double(nb_dfmemlEstimator.getObservables(results,options));
    results.smoothed.observables = struct('data',observables,'startDate',toString(sDate),'variables',{options.observablesOrig});
    
    % Construct the vector of estimated parameters
    results = reorderObservables(options,results);
    results = collectCoefficients(options,results);
    
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
% time-trend, seasonal terms or any user defined variable

    C = nan(size(W,2),size(X,2));
    if options.constant 
        % Estimate contant term using mean of X
        C(1,:) = mean(X,'omitnan');
    end

    if options.constant && size(W,2) == 1
        Xhat = bsxfun(@minus,X,C);
        return
    end
    
    for ii = 1:size(X,2)
    
        % Balance the dataset
        isNaN = any(isnan(X(:,ii)),2) | any(isnan(W),2);
        Xest  = X(~isNaN,ii);
        West  = W(~isNaN,ii);

        % Estimate the impact of exogenous variables using OLS on the
        % stripped data
        C(ii,2:end) = nb_ols(Xest,West);
        
    end
    Xhat = X - W*C;
    
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

    results.C = results.C(options.reorderLoc,:);
    results.Z = results.Z(options.reorderLoc,:);
    if ~isempty(results.S)
        results.S = results.S(options.reorderLoc,:);
    end
    
end

%==========================================================================
function results = collectCoefficients(options,results)
% Create a vector of coefficients, the naming of the parameters can be
% found in nb_dfmemlEstimator.getCoeff

    % Transtion of factors coefficients
    if options.factorRestrictions
        nTransCoeff = options.nFactors*options.nLags;
        incr        = options.nFactors;
        start       = 1:options.nFactors;
    else
        nTransCoeff = options.nFactors^2*options.nLags;
        incr        = 1;
        start       = ones(1,options.nFactors);
    end
    if options.nLagsIdiosyncratic
        nTransCoeff = nTransCoeff + size(results.Z,1);
    end
    A = nan(nTransCoeff,1);
    k = 1;
    for ii = 1:options.nFactors
        % Index of the wanted factor including lags of the transition
        % matrix.
        ind = start(ii):incr:options.nFactors*options.nLags;

        % Estimates for this factor (eq 6)
        TT         = results.T(ii,ind);
        n          = numel(TT);
        A(k:k+n-1) = TT(:);
        k          = k + n;
    end

    % Transition of idiosyncatic components
    if options.nLagsIdiosyncratic
        indEps     = nb_dfmemlEstimator.getEpsInd(options);
        TT         = diag(results.T(indEps,indEps));
        n          = numel(TT);
        A(k:k+n-1) = TT(:);
    end

    % Loadings
    L       = results.Z(:,1:options.nFactors);
    L       = L(:);
    L(L==0) = [];
    
    results.beta = [...
        results.C(:);
        results.S(:);
        L;
        A];
    
    if options.nLagsIdiosyncratic == 0
        if options.mixedFrequency
            % Order the variance of the idiosyncratic low frequency  
            % component last 
            nFac         = options.nFactors;
            diagQ        = diag(results.Q);
            nHigh        = options.nHigh;
            results.beta = [results.beta;diagQ(1:nFac);diag(results.R(1:nHigh,1:nHigh));diagQ(nFac+1:end)];
        else
            results.beta = [results.beta;diag(results.Q);diag(results.R)];
        end
    else
        results.beta = [results.beta;diag(results.Q)];
    end

end
