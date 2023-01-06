function [beta,sigma,R,yM,X,posterior] = glpMF(draws,y,x,nLags,constant,timeTrend,prior,restrictions,waitbar,freq,H,mixing)
% Syntax:
%
% [beta,sigma,R,yM,X,posterior,prior] = nb_bVarEstimator.glpMF(draws,y,x,...
%    nLags,constant,constantAR,timeTrend,prior,restrictions,waitbar,...
%    freq,H,mixing)
%
% Description:
%
% Estimate VAR model using prior used in the paper by Giannone, Lenza and
% Primiceri (2014), "Prior selection for vector autoregressions" and 
% Giannone, Lenza and Primiceri (2017), "Priors for the long run". In
% contrast to the nb_bVarEstimator.glp prior this prior also handle 
% missing observations (but not mixed frequency VARs!).
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
% - timeTrend    : If a linear time trend is wanted in the estimation. 
%                  Will be added first/second in the right hand side 
%                  variables. (First if constant is not given, else 
%                  second) 
%
% - prior        : A struct with the prior options. See
%                  nb_var.priorTemplate for more on this input
%
% - restrictions : Index of parameters that are restricted to zero.
%
% - waitbar      : true, false or an object of class nb_waitbar5.
%
% - empirical    : A struct with the options on how to do the empirical 
%                  bayesian. Default is empty, i.e. do not do empirical
%                  bayesian.
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
% - X          : Regressors including constant and time-trend.
% 
% - yM         : Observations on the dependent variables. Mean estimates
%                of the unobserved values are returned. Including lags.
%
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% - fVal       : Initial log posterior on the full balanced sample.
%
% - prior      : Updated prior structure. I.e. the optimized
%                hyperparameters will be reset if empirical bayesain is 
%                done.
% 
% See also
% nb_bVarEstimator.estimate, nb_var, nb_bVarEstimator.glp
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    if isfield(prior,'maxTries')
        maxTries = prior.maxTries;
    else
        maxTries = 100;
    end

    if ~isempty(restrictions)
        error([mfilename ':: Block exogenous variables cannot be declared with the Giannone, Lenza and Primiceri (2014) prior.'])
    end
    
    S_scale = 1;
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    end
    
    % Initialize priors
    %-----------------------
    
    % Prior on measurement error variance
    [Traw,numDep] = size(y);
    R_prior = zeros(numDep,1);  
    if ~isempty(mixing)
        indObservedOnly = mixing.indObservedOnly;
        numDep          = numDep - sum(indObservedOnly);
    else
        indObservedOnly = false(1,numDep);
    end
    if timeTrend
        trend = 1:Traw;
        x     = [trend', x];
    end
    if constant        
        x = [ones(Traw,1), x];
    end
    
    % Are we dealing with all zero regressors?
    [x,indZR]     = nb_bVarEstimator.removeZR(x,false,false,numDep,nLags);
    nExo          = size(x,2);
    numCoeff      = nExo + nLags*numDep;
    
    % Get the prior options
    lambda  = prior.lambda;
    Vc      = prior.Vc;
    ARcoeff = prior.ARcoeff;
    
    % Prior mean on VAR regression coefficients
    %------------------------------------------
    A_prior = [zeros(nExo,numDep); ARcoeff*eye(numDep); zeros((nLags-1)*numDep,numDep)];   
    a_prior = A_prior(:);
    if isfield(prior,'coeffInt')
        % Specific priors, see nb_estimator.getSpecificPriors
        p               = prior.coeffInt;
        a_prior(p(:,1)) = p(:,2);
    end
    
    % Minnesota Variance on VAR regression coefficients
    %--------------------------------------------------
    nLagsAR = 1;
    s_prior = nb_bVarEstimator.minnesotaVariancePrior(prior,y,constant,timeTrend,H,freq,mixing,indObservedOnly,nLagsAR);
    
    % Setting up the priors (See appendix B of GLP (2017))
    %----------------------------------------------------------------------
    v_prior         = zeros(numCoeff,1);
    v_prior(1:nExo) = Vc;
    numDep2         = numDep + 2;
    for ii = 1:nLags
        ind          = nExo + (ii - 1)*numDep + 1:nExo + ii*numDep;
        v_prior(ind) = (numDep2 - numDep - 1)*(lambda^2)*(1/(ii^2))./s_prior;
    end
    V_prior_inv = diag(1./v_prior);
    
    % Prior scale matrix for the covariance of the shocks. See Kadiyala 
    % and Karlsson (1997)
    S_prior =  S_scale*diag(s_prior);
    
    % sigma | Y ~ IW(S_post,v_post)
    v_post = Traw - nLags + numDep + 2;
    
    % Simulate from posterior using Gibbs sampler
    if isfield(prior,'burn')
        burn = prior.burn;
    else
        burn = 2;
    end
    if isfield(prior,'thin')
        thin = prior.thin;
    else
        thin = 2;
    end
    
    % Check that the prior gives as stationary model
    numRows = (nLags - 1)*numDep;
    A       = [A_prior(nExo+1:end,:)'; eye(numRows),zeros(numRows,numDep)];
    [~,~,m] = nb_calcRoots(A);
    if any(m > 1)
        error([mfilename ':: The prior must provide a stationary process. Reset the ARcoeff or coeff prior options.'])
    end
    
    % Set up prior on measurement error covariance matrix. Here using a
    % dogmatic prior for now...
    if any(indObservedOnly) && ~isempty(mixing)
        % Even if all observation of the series are nan, this is not a
        % problem as the nan elements of R will never be used!
        if isscalar(prior.R_scale)
            R_prior(mixing.loc) = nanvar(y(:,mixing.loc))/prior.R_scale;
        else
            varDep                      = nanvar(y(:,prior.R_scale(:,1)))';
            R_prior(prior.R_scale(:,1)) = varDep./prior.R_scale(:,2);
        end
    end
    
    % Collect dummy prior options
    dummyPriorOptions = nb_bVarEstimator.getDummyPriorOptions(nLags,prior,constant,timeTrend);
    
    % Gibbs sampler
    R                  = R_prior; 
    [beta,sigma,yD,pD] = nb_bVarEstimator.nwishartMFGibbs(draws,y,x,H,R,A_prior,S_prior,...
        a_prior,V_prior_inv,S_prior,v_post,restrictions,thin,burn,waitbar,maxTries,dummyPriorOptions);

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
    if nargout > 3
        posterior = struct('type','glpMF','betaD',beta,'sigmaD',sigma,'dependent',y,'yD',yD,'pD',pD,...
                           'regressors',x,'H',H,'a_prior',a_prior,'S_prior',S_prior,'v_post',v_post,...
                           'V_prior_inv',V_prior_inv,'restrictions',{restrictions},'R_prior',R,...
                           'maxTries',maxTries,'thin',thin,'burn',burn,'dummyPriorOptions',dummyPriorOptions);               
    end
    
end


