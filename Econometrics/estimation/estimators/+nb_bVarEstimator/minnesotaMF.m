function [beta,sigma,R,yM,X,posterior] = minnesotaMF(draws,y,x,nLags,constant,...
    timeTrend,prior,restrictions,waitbar,freq,H,mixing)
% Syntax:
%
% [beta,sigma,R,yM,X,posterior] = nb_bVarEstimator.minnesotaMF(draws,y,x,...
%                        nLags,constant,timeTrend,prior,restrictions,...
%                        waitbar,freq,H,mixing)
%
% Description:
%
% Estimate mixed frequency or missing observations B-VAR model using 
% minnesota type prior. This method extends nb_bVarEstimator.minnesota.
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x h. Where h is the 
%                  exogenous variables of the model.
%
% - nLags        : Number of lags of the VAR. As an integer
%
% - constant     : If a constant is wanted in the estimation. Will be
%                  added first in the right hand side variables.
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
% - freq         : A 1 x nDep int with the frequencies of the variables
%                  of the MF-VAR. Is empty if VAR with missing
%                  observations.
%
% - H            : Mapping of the measurement equation of the state-space
%                  representation of the missing observation VAR or MF-VAR
%                  model.
%
% - mixing       : A struct with the information on the variables that
%                  are observed with different frequencies.
%
%                  If empty, it is assumed that no variable is measured
%                  with more than one frequency.
%
% Output: 
% 
% - beta       : A (extra + neq*nlags + h) x neq x draws matrix with the  
%                posterior draws of the estimted coefficents.
%
% - sigma      : A neq x neq x draws matrix with the posterior variance of 
%                the the estimated coefficients. 
%
% - R          : A nobs x nobs double matrix with the measurement error
%                covariance matrix.
%
% - yM         : Observations on the dependent variables. Mean estimates
%                of the unobserved values are returned. Including lags.
%
% - X          : Regressors including constant and time-trend. The mean
%                of the unobserved values is returned.
%
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% See also
% nb_bVarEstimator, nb_var, nb_mfvar 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isfield(prior,'maxTries')
        maxTries = prior.maxTries;
    else
        maxTries = 100;
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
    
    % Initialize priors
    %-----------------------
    [Traw,numDep] = size(y); 
    if ~isempty(mixing)
        indObservedOnly = mixing.indObservedOnly;
        numDep          = numDep - sum(indObservedOnly);
    else
        indObservedOnly = false(1,numDep);
    end
    
    % Are we dealing with all zero regressors?
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,nLags,restrictions);
    nExo                   = size(x,2) + constant + timeTrend;
    numCoeff               = nExo + nLags*numDep;
    
    % Get the prior options
    a_bar_1 = prior.a_bar_1;
    a_bar_2 = prior.a_bar_2;
    a_bar_3 = prior.a_bar_3;
    ARcoeff = prior.ARcoeff;
    if isnan(ARcoeff)
        error('Cannot set ARcoeff prior to nan for the prior minnesotaMF')
    end
    
    % Prior mean on VAR regression coefficients
    %------------------------------------------
    initBeta = [zeros(nExo,numDep); ARcoeff*eye(numDep); zeros((nLags-1)*numDep,numDep)];  %<---- prior mean of ALPHA (parameter matrix) 
    a_prior  = initBeta(:);
    if isfield(prior,'coeffInt')
        % Specific priors, see nb_estimator.getSpecificPriors
        p               = prior.coeffInt;
        a_prior(p(:,1)) = p(:,2);
    end
    
    % Minnesota Variance on VAR regression coefficients
    %--------------------------------------------------
    sigma_sq = nb_bVarEstimator.minnesotaVariancePrior(prior,y,constant,...
        timeTrend,H,freq,mixing,indObservedOnly,nLags);
    
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
    
    % Now V is a diagonal matrix with diagonal elements V_i
    V_prior = diag(V_i_jj);  % this is the prior variance of the vector alpha
    
    % Intial value of sigma (For MCI this is asummed known, so it is not
    % drawn)
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
    
    % Set up prior on measurement error covariance matrix. Here using a
    % dogmatic prior for now...
    R_prior = nb_bVarEstimator.setUpPriorMeasEqCovMat(y,...
        indObservedOnly,mixing,prior);
    
    % Check that the prior gives as stationary model
    numRows = (nLags - 1)*numDep;
    A       = [initBeta(nExo+1:end,:)'; eye(numRows),zeros(numRows,numDep)];
    [~,~,m] = nb_calcRoots(A);
    if any(m > 1)
        error(['The prior must provide a stationary process. Reset the ',...
            'ARcoeff or coeff prior options.'])
    end
    
    % Collect dummy prior options
    dummyPriorOptions = nb_bVarEstimator.getDummyPriorOptions(nLags,...
        prior,constant,timeTrend);
    
    % Gibbs sampling
    R = R_prior;
    if ~strcmpi(method,'default')
        v_post             = Traw + numDep + 1;
        S_prior            = S_scale*eye(numDep); % prior scale of SIGMA 
        [beta,sigma,yD,pD] = nb_bVarEstimator.minnesotaMFGibbs(draws,y,x,H,R_prior,initBeta,initSigma,...
            a_prior,V_prior,S_prior,v_post,restrictions,burn,thin,waitbar,maxTries,dummyPriorOptions);
    else
        % No sampling of sigma
        v_post             = [];
        S_prior            = [];
        [beta,sigma,yD,pD] = nb_bVarEstimator.minnesotaMFGibbs2(draws,y,x,H,R_prior,initBeta,initSigma,...
            a_prior,V_prior,restrictions,burn,thin,waitbar,maxTries,dummyPriorOptions);
    end
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return the mean estimates of unobservables
    yM    = mean(yD,3);
    yMLag = yM(:,numDep+1:numDep*(nLags+1),:);
    X     = [x(nLags+1:end,:),yMLag]; % Exogenous and lags
    X     = kron(eye(numDep),X);
    if ~isempty(restrictions)
        X = X(:,restr);
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','minnesotaMF','betaD',beta,'sigmaD',sigma,'yD',yD,'pD',pD,...
                           'dependent',y,'regressors',x,'a_prior',a_prior,'V_prior',V_prior,...
                           'restrictions',{restrictions},'method',method,'burn',burn,...
                           'thin',thin,'S_prior',S_prior,'v_post',v_post,'H',H,'R_prior',R_prior,...
                           'maxTries',maxTries,'dummyPriorOptions',dummyPriorOptions);
    end
    
end

