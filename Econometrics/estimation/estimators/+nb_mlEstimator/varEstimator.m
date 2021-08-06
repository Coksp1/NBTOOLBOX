function [beta,stdBeta,tStatBeta,pValBeta,sigma,residual,ys,lik,Omega] = varEstimator(y,X,options,init)
% Syntax:
%
% [beta,stdBeta,tStatBeta,pValBeta,sigma,residual,ys,XX,lik,Omega] = 
% nb_mlEstimator.varEstimator(y,X,options,init)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initialize
    %----------------------------------------------------------------------
    nLags     = options.nLags;
    nExo      = size(X,2) + options.constant + options.time_trend;
    nDep      = size(y,2);
    nCoeffExo = nExo*nDep;
    nCoeffDyn = nDep^2*nLags;

    % First we estimate the model by OLS 
    Z       = [y,X];
    missing = false;
    if any(isnan(Z(:)))
        missing = true;
    end
    
    if isempty(init)
        
        if missing
            
            % zero initialization
            ind    = ~any(isnan(Z),2);
            start  = find(ind,1);
            finish = find(ind,1,'last');
            check  = any(~ind(start:finish));
            if check
                betaExo  = zeros(nCoeffExo,1);
                betaDyn  = zeros(nCoeffDyn,1);
                sigma    = eye(nDep);
                sigmaPar = nb_reduceCov(sigma);
                yOLS     = [];
            else
                yOLS = y(start:finish,:);
                XOLS = X(start:finish,:);
            end
        else
            yOLS = y;
            XOLS = X;
        end

        if ~isempty(yOLS)
        
            tSample = options.nLags+1:size(yOLS,1);
            yLag    = nb_mlag(yOLS,options.nLags,'varFast');
            yLag    = yLag(tSample,:);
            yTemp   = yOLS(tSample,:);
            Xtemp   = XOLS(tSample,:);

            % OLS initialization
            if isempty(options.restrictions)
                [beta,~,~,~,res] = nb_ols(yTemp,[Xtemp,yLag],options.constant,options.time_trend);
            else
                [beta,~,~,~,res] = nb_olsRestricted(yTemp,[Xtemp,yLag],options.restrictions,options.constant,options.time_trend);
            end
            beta     = beta';
            beta     = beta(:);
            betaExo  = beta(1:nCoeffExo);
            betaDyn  = beta(nCoeffExo+1:nCoeffExo+nCoeffDyn);
            T        = size(res,1);
            numCoeff = size(beta,2);
            sigma    = res'*res/(T - numCoeff);
            sigmaPar = nb_reduceCov(sigma);

        end
        
    else % Initial value taken from past iteration
        betaExo  = init(1:nCoeffExo);
        betaDyn  = init(nCoeffExo+1:nCoeffExo+nCoeffDyn);
        sigmaPar = init(nCoeffExo+nCoeffDyn+1:end);
    end
    
    % Restrictions
    if ~isempty(options.restrictions)
        restr    = ~reshape([options.restrictions{:}]',[],nDep)';
        betaDyn  = betaDyn(~restr(:));
    else
        restr = false(size(betaDyn));
    end
    restrVal = zeros(size(restr));       

    % Initial parameters
    par = [betaExo;betaDyn;sigmaPar];
    if ~missing
        % Run a stability check of initial estimates
        [~,~,~,~,A]     = nb_var.stateSpace(par,nDep,nLags,nCoeffExo,restr,restrVal);
        [~,~,modulus]   = nb_calcRoots(A);
        if any(modulus >= 1)
            error([mfilename ':: Initial parameter vector results in an unstable VAR model.'])
        end
    end
    
    % Estimate the parameters by maximum likelihood
    %----------------------------------------------------------------------
    
    % Get the data in the way we need for the Kalman filter
    T = size(y,1);
    if options.time_trend
        tt = 1:T;
        X  = [tt',X];
    end
    if options.constant
        X = [ones(T,1),X];
    end
    
    options       = nb_defaultField(options,'optimizer','fminunc');
    options       = nb_defaultField(options,'optimset',optimset());
    options       = nb_defaultField(options,'kf_presample','fminunc');
    stabilityTest = options.stabilityTest;
    
    % Get bounds
    UB      = inf(size(par,1),1);
    LB      = -UB;
    LBsigma = -inf(sum(1:nDep),1);
    kk      = nDep;
    ll      = 1;
    for ii = 1:nDep
        LBsigma(ll) = 0;
        ll          = ll + kk;
        kk          = kk - 1;
    end
    LB(nCoeffExo+nCoeffDyn+1:end) = LBsigma;
    
    % Minimize the minus the log likelihood 
    if missing
        fh = @nb_kalmanlikelihood_missing;
    else
        fh = @nb_kalmanlikelihood;
    end
    if strcmpi(options.optimizer,'nb_abc')
        error([mfilename ':: The nb_abc optimizer is not supported for a model of class nb_arima.'])
    end
    [estPar,lik,Hessian] = nb_callOptimizer(options.optimizer,fh,par,LB,UB,options.optimset,...
                                ':: Estimation of the VAR model failed.',@nb_var.stateSpace,y',X',...
                                options.kf_presample+1,nDep,nLags,nCoeffExo,restr,restrVal,stabilityTest);
    
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
    
    % Smoothing residuals
    %----------------------------------------------------------------------
    if missing
        [~,ys,residual,~] = nb_kalmansmoother_missing(@nb_var.stateSpace,y',X',estPar,nDep,nLags,nCoeffExo,restr,restrVal);
    else
        [~,ys,residual,~] = nb_kalmansmoother(@nb_var.stateSpace,y',X',estPar,nDep,nLags,nCoeffExo,restr,restrVal);
    end
    
end
