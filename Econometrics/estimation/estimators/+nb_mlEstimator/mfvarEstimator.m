function [beta,stdBeta,tStatBeta,pValBeta,sigma,residual,ys,lik,Omega] = mfvarEstimator(y,X,options,H,init)
% Syntax:
%
% [beta,stdBeta,tStatBeta,pValBeta,sigma,residual,ys,ysl,lik,Hessian] = 
% nb_mlEstimator.mfvarEstimator(y,X,options,H,init)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get mixing options
    nObs                   = size(y,2);
    mixing.indObservedOnly = options.indObservedOnly;
    vars                   = [options.dependent,options.block_exogenous];
    varsMixing             = vars(~mixing.indObservedOnly);
    [~,mixing.loc]         = ismember(options.mixing(options.indObservedOnly),vars);
    [~,mixing.locIn]       = ismember(options.mixing(options.indObservedOnly),varsMixing);
    nDep                   = nObs - sum(options.indObservedOnly);

    % Initialize
    %----------------------------------------------------------------------
    nLags     = options.nLags;
    nExo      = size(X,2) + options.constant + options.time_trend;
    nCoeffExo = nExo*nDep;
    nCoeffDyn = nDep^2*nLags;
    
    if isempty(init)
        [betaExo,betaDyn,sigmaPar] = nb_mlEstimator.getInitMFVAR(y(:,~mixing.indObservedOnly),X,options,'interpolate',H(~mixing.indObservedOnly,:,:)); 
    else % Initial value taken from past iteration
        betaExo  = init(1:nCoeffExo);
        betaDyn  = init(nCoeffExo+1:nCoeffExo+nCoeffDyn);
        sigmaPar = init(nCoeffExo+nCoeffDyn+1:end);
    end
    
    % Restrictions
    if ~isempty(options.restrictions)
        restr    = ~reshape([options.restrictions{:}]',[],nDep)';
        betaDyn  = betaDyn(:);
        betaDyn  = betaDyn(~restr(:));
    else
        restr    = false(size(betaDyn));
    end
    restrVal = zeros(size(restr));       
    
    % Measurment errors
    R = zeros(nObs,1);

    % Initial parameters
    par = [betaExo;betaDyn;sigmaPar;R(options.measurementErrorInd)];
    
    % Estimate the parameters by maximum likelihood
    %----------------------------------------------------------------------
    
    % Add constant and time-trend if wanted
    T = size(y,1);
    if options.time_trend
        tt = 1:T;
        X  = [tt',X];
    end
    if options.constant
        X = [ones(T,1),X];
    end
    
    options       = nb_defaultField(options,'optimizer','fmincon');
    options       = nb_defaultField(options,'optimset',optimset('fmincon'));
    options       = nb_defaultField(options,'kf_presample',0);
    stabilityTest = options.stabilityTest;
    
    % Get bounds
    nMeasErr = length(options.measurementErrorInd);
    UB       = inf(size(par,1),1);
    LB       = -UB;
    LBsigma  = -inf(sum(1:nDep),1);
    kk       = nDep;
    ll       = 1;
    for ii = 1:nDep
        LBsigma(ll) = 0;
        ll          = ll + kk;
        kk          = kk - 1;
    end
    LB(nCoeffExo+nCoeffDyn+1:end-nMeasErr) = LBsigma;
    LB(end-nMeasErr+1:end)                 = 0;
    
    % Minimize the minus the log likelihood 
    if strcmpi(options.optimizer,'nb_abc')
        error([mfilename ':: The nb_abc optimizer is not supported for a model of class nb_arima.'])
    end
    [estPar,lik,Hessian] = nb_callOptimizer(options.optimizer,@nb_kalmanlikelihood_missing,par,LB,UB,options.optimset,...
                                ':: Estimation of the VAR model failed.',@nb_mfvar.stateSpace,y',X',...
                                options.kf_presample+1,nDep,nLags,nCoeffExo,restr,restrVal,options.measurementErrorInd,H,stabilityTest);
    
    % Standard deviation of the estimated paramteres (estPar)
    Hessian = Hessian(1:nCoeffExo+nCoeffDyn,1:nCoeffExo+nCoeffDyn);
    if rcond(Hessian) < eps^(0.9)
        error([mfilename ':: Standard error of paramters cannot be calulated. Hessian is badly scaled.'])
    else
        Omega     = eye(size(Hessian,1))/Hessian;
        stdEstPar = sqrt(diag(Omega));
        if any(~isreal(stdEstPar))
            if options.covrepair
                Omega     = nb_covrepair(Omega,false);
                stdEstPar = sqrt(diag(Omega));
                if any(~isreal(stdEstPar))
                    error([mfilename ':: Standard error of paramters cannot be calulated. Hessian is badly scaled. Even the covrepair option did not work out...'])
                end
            else
                error([mfilename ':: Standard error of paramters are not real, something went wrong. You may want to use the covrepair option...'])
            end
        end
    end
    
    % Reporting
    %----------------------------------------------------------------------
    nDepPar         = sum(~restr(:));
    betaExo         = estPar(1:nCoeffExo)';
    betaDyn         = zeros(nDep,nDep*nLags);
    stdDyn          = betaDyn;
    betaDyn(~restr) = estPar(nCoeffExo+1:nCoeffExo+nDepPar);
    betaDyn(restr)  = restrVal(restr);
    beta            = [betaExo;betaDyn'];
    stdExo          = stdEstPar(1:nCoeffExo)'; 
    stdDyn(~restr)  = stdEstPar(nCoeffExo+1:nCoeffExo+nDepPar);
    stdBeta         = [stdExo;stdDyn'];
    sigma           = nb_expandCov(estPar(nCoeffExo+nDepPar+1:end),nDep);
    
    % t-statistics
    tStatBetaStacked = beta(:)./stdBeta(:);
    tStatBeta        = reshape(tStatBetaStacked,[],nDep);
    
    % p-values
    try
        pValBetaStacked = nb_tStatPValue(tStatBetaStacked,T-(nCoeffExo+nDepPar)/nDep);
    catch %#ok<CTCH>
       error('t-statistic not valid. Probably due to colinearity or missing observations?!') 
    end
    pValBeta  = reshape(pValBetaStacked,[],nDep);
    
    % Smoothing variables and residuals
    %----------------------------------------------------------------------
    [~,ys,residual] = nb_kalmansmoother_missing(@nb_mfvar.stateSpace,y',X',estPar,nDep,nLags,nCoeffExo,restr,restrVal,options.measurementErrorInd,H);
    
end
