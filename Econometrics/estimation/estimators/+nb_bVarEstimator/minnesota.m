function [beta,sigma,X,posterior] = minnesota(draws,y,x,nLags,constant,constantAR,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,X] = nb_bVarEstimator.minnesota(draws,y,x,nLags,constant,...
%                     constantAR,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using minnesota prior.
%
% This code is based on the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
% See page 7 of Koop and Korobilis (2009).
%
% See also the documentation DAG.pdf.
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x h + neq*nlags. Where h
%                  is the exogenous variables of the model.
%
% - nLags        : Number of lags of the VAR. As an integer
%
% - constant     : If a constant is wanted in the estimation. Will be
%                  added first in the right hand side variables.
% 
% - constantAR   : Include constant in AR models that is used to set up 
%                  the prior for sigma.
%
% - timeTrend    : If a linear time trend is wanted in the estimation. 
%                  Will be added first/second in the right hand side 
%                  variables. (First if constant is not given, else 
%                  second) 
%
% - prior        : A struct with the prior options. See
%                  nb_bVarEstimator.priorTemplate for more on this input
%
% - restrictions : Index of parameters that are restricted to zero.
%
% - waitbar      : true, false or an object of class nb_waitbar5.
%
% Output: 
% 
% - beta       : A (extra + neq*nlags + h) x neq x draws matrix with the  
%                posterior draws of the estimted coefficents.
%
% - sigma      : A neq x neq x draws matrix with the posterior variance of 
%                the the estimated coefficients. 
%
% - X          : Regressors including constant and time-trend.
% 
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% See also
% nb_bVarEstimator, nb_var 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 9
        waitbar = 0;
        if nargin < 8
            restrictions = {};
            if nargin < 7
                prior = nb_bVarEstimator.priorTemplate('minnesota');
                if nargin < 6
                    timeTrend = 0;
                    if nargin < 5
                        constant = 0;
                    end
                end
            end
        end
    end

    method = 'default';
    if isfield(prior,'method')
        method = prior.method;
        if strcmpi(method,'mci')
            method = 'default'; 
        end
    end
    burn = 500;
    if isfield(prior,'burn')
        burn = prior.burn;
    end
    thin = 5;
    if isfield(prior,'thin')
        thin = prior.thin;
    end
    S_scale = 1;
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    end
    
    % Are we dealing with all zero regressors?
    [Traw,numDep]          = size(y);
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0,restrictions);
    
    % Initialize priors
    %-----------------------
    numCoeff = size(x,2) + constant + timeTrend;
    nExo     = numCoeff - nLags*numDep;
    
    % Get the prior options
    a_bar_1 = prior.a_bar_1;
    a_bar_2 = prior.a_bar_2;
    a_bar_3 = prior.a_bar_3;
    ARcoeff = prior.ARcoeff;
    
    % Minnesota Variance on VAR regression coefficients
    %--------------------------------------------------
    TrawAR = Traw;
    if isfield(prior,'LR')
        % We don't want the dummy observation prior mess up the 
        % minnesota prior itself, so here we remove the dummy
        % observation temporarily
        if prior.LR || prior.SC 
            TrawAR = TrawAR - numDep;
        end
        if prior.DIO
            TrawAR = TrawAR - 1;
        end
        if prior.SVD
            TrawAR = min(TrawAR,prior.obsSVD - 1);
        end
        yT = y(1:TrawAR,:);
    else
        yT = y;
    end

    % Prior mean on VAR regression coefficients
    %------------------------------------------
    if isnan(ARcoeff)
        ARcoeffEach = nb_bVarEstimator.getARCoeffs(yT,TrawAR,constantAR,timeTrend,prior.indCovid);
        priorBeta   = [zeros(nExo,numDep); diag(ARcoeffEach); zeros((nLags-1)*numDep,numDep)];  %<---- prior mean of ALPHA (parameter matrix)
    else
        priorBeta = [zeros(nExo,numDep); ARcoeff*eye(numDep); zeros((nLags-1)*numDep,numDep)];  %<---- prior mean of ALPHA (parameter matrix)
    end
    a_prior   = priorBeta(:);
    if isfield(prior,'coeffInt')
        % Specific priors, see nb_estimator.getSpecificPriors
        p               = prior.coeffInt;
        a_prior(p(:,1)) = p(:,2);
    end
    priorBeta = reshape(a_prior,[numCoeff,numDep]);
    
    % Now get residual variances of univariate p_MIN-lag autoregressions. 
    % Here we just run the AR(p) model on each equation, ignoring the 
    % constant and exogenous variables (if they have been specified for the 
    % original VAR model)
    normFac  = nLags + (1 + constantAR + timeTrend); 
    sigma_sq = zeros(1,numDep);
    for ii = 1:numDep
        
        % Create lags of dependent variables   
        yLag_i = nb_mlag(yT(:,ii),nLags);
        yLag_i = yLag_i(nLags+1:TrawAR,:);
        y_i    = yT(nLags+1:TrawAR,ii);
        
        if ~isempty(prior.indCovid)
            y_i    = y_i(prior.indCovid(nLags+1:TrawAR));
            yLag_i = yLag_i(prior.indCovid(nLags+1:TrawAR));
        end

        % OLS estimates of i-th equation
        [~,~,~,~,res] = nb_ols(y_i,yLag_i,constant,timeTrend);
        sigma_sq(ii)  = (1./(TrawAR-normFac))*(res'*res);
        
    end
    
    % Now define prior hyperparameters. See Koop and Korobilis (2009) page
    % 6
    %----------------------------------------------------------------------
    V_i_jj = zeros(numCoeff,numDep);
    exoInd = 1:nExo;
    
    % Priors on coefficients on exogenous variables
    V_i_jj(exoInd,:) = a_bar_3*repmat(sigma_sq,[nExo,1]);
    a_bar            = repmat(a_bar_2,numDep*nLags,1); 
    sigma_sq_rep     = repmat(sigma_sq',nLags,1); 
    endoInd          = nExo + 1:numCoeff;
    nLagsSq          = repmat((1:nLags).^2,[numDep,1]);
    nLagsSq          = nLagsSq(:);
    for ii = 1:numDep 
        
        % Prior on own lags
        a_bar_i     = a_bar;
        a_bar_i(ii) = a_bar_1; % Hyperparamter on own lags
        
        % Assign
        V_i_jj(endoInd,ii) = (a_bar_i./nLagsSq).*(sigma_sq(ii)./sigma_sq_rep);
       
    end
    V_i_jj = V_i_jj(:);
    if ~isempty(restrictions)
        restr   = [restrictions{:}];
        V_i_jj  = V_i_jj(restr);
        a_prior = a_prior(restr);
    end
    
    % Now V is a diagonal matrix with diagonal elements the V_i
    V_prior = diag(V_i_jj);  % this is the prior variance of the vector alpha
    
    % Prior scale matrix for the covariance of the shocks. See Kadiyala 
    % and Karlsson (1997)
    initSigma = diag(sigma_sq);
    
    % Add time trend if wanted
    if timeTrend
        trend = 1:Traw;
        x     = [trend', x];
    end
    
    % Add constant if wanted
    if constant        
        x = [ones(Traw,1), x];
    end
    
    % Strip observations
    [y,x,Traw] = nb_bVarEstimator.stripObservations(prior,y,x);

    % Expand regressors and remove the variables 
    % restricted to be zero
    %-------------------------------------------
    X = kron(eye(numDep),x);
    if ~isempty(restrictions)
        X = X(:,restr);
    end
    
    % Monte carlo integration or gibbs sampling
    %------------------------------------------
    if ~strcmpi(method,'default')
        v_post       = Traw - nLags + numDep + 1;
        S_prior      = S_scale*initSigma; % prior scale of SIGMA 
        [beta,sigma] = nb_bVarEstimator.minnesotaGibbs(draws,y,X,priorBeta,...
            initSigma,a_prior,V_prior,S_prior,v_post,restrictions,burn,thin,waitbar);
    else
        v_post       = [];
        S_prior      = [];
        [beta,sigma] = nb_bVarEstimator.minnesotaMCI(draws,y,X,priorBeta,...
            initSigma,a_prior,V_prior,restrictions);
    end
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','minnesota','betaD',beta,'sigmaD',sigma,'dependent',y,...
                           'regressors',X,'a_prior',a_prior,'V_prior',V_prior,...
                           'restrictions',{restrictions},'method',method,'burn',burn,...
                           'thin',thin,'S_prior',S_prior,'v_post',v_post);
    end
    
end
