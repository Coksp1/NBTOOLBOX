function [beta,sigma,R,yM,X,posterior] = nwishartMF(draws,y,x,nLags,constant,timeTrend,prior,restrictions,waitbar,H,mixing)
% Syntax:
%
% [beta,sigma,R,yM,X,posterior] = nb_bVarEstimator.nwishartMF(draws,y,x,...
%                   nLags,constant,timeTrend,prior,restrictions,waitbar,...
%                   H,mixing)
%
% Description:
%
% Estimate missing observation or mixed frequency VAR model using 
% a Normal-Wishart prior.
%
% This code is extending nb_bVarEstimator.nwishart.
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
% - waitbar      : true, false or an object of class nb_waitbar.
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
% - R          : A nobs x 1 double matrix with the measurement error
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

    if ~isempty(restrictions)
        error('Block exogenous variables cannot be declared with the nwishart prior.')
    end
    
    [T,numDep] = size(y); 
    if ~isempty(mixing)
        indObservedOnly = mixing.indObservedOnly;
        numDep          = numDep - sum(indObservedOnly);
    else
        indObservedOnly = false(1,numDep);
    end
    
    % Are we dealing with all zero regressors?
    [x,indZR] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,nLags);
    nExo      = size(x,2) + constant + timeTrend;
    numCoeff  = nExo + nLags*numDep;

    % Hyperparameters on a ~ N(a_prior, SIGMA x V_prior)
    a_prior     = zeros(numCoeff*numDep,1); 
    V_prior_inv = (1/prior.V_scale)*eye(numCoeff);
    
    % Remove mixing variables from measurement equation used for 
    % setting up the prior
    yPrior = y(:,~indObservedOnly);
    Hprior = H(~indObservedOnly,:,:);
    
    % Fill in for the missing values to get initial estimates. Here we use 
    % a AR(1) specification on the variables with missing values.
    ys = yPrior;
    for ii = 1:numDep
        yi = yPrior(:,ii);
        if any(isnan(yi)) 
            nDep = size(Hprior,1);   
            Hi   = Hprior(ii,ii:nDep:end,:);
            if size(Hi,3) > 1
                ind = find(any(Hi ~= 0,3),1,'last');
            else
                ind = find(Hi ~= 0,1,'last');
            end
            Hi             = Hi(:,1:ind,:);
            [~,~,ys(:,ii)] = nb_bVarEstimator.estimateARLowFreq(yi,Hi);
        end
    end
    
    % Construct right hand side regressors
    ysLag = nb_mlag(ys,nLags,'varFast');
    X     = [x,ysLag];
    X     = X(nLags+1:end,:);
    ys    = ys(nLags+1:end,:); 
      
    % Initial values for Gibbs
    [A_OLS,~,~,~,r] = nb_ols(ys,X,constant,timeTrend);
    SSE             = r'*r;
    initSigma       = SSE./(T-size(a_prior,1)+1);
    
    % Hyperparameters on inv(SIGMA) ~ W(v_prior,inv(S_prior))
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    else
        S_scale = 1;
    end
    v_prior = numDep + 1;             
    S_prior = S_scale*eye(numDep);  
    v_post  = T + v_prior;
    
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
    
    % Add time trend if wanted
    if timeTrend
        trend = 1:T;
        x     = [trend', x];
    end
    
    % Add constant if wanted
    if constant        
        x = [ones(T,1), x];
    end
    
    % Set up prior on measurement error covariance matrix. Here using a
    % dogmatic prior for now...
    R_prior = nb_bVarEstimator.setUpPriorMeasEqCovMat(y,...
        indObservedOnly,mixing,prior);
    
    % Collect dummy prior options
    dummyPriorOptions = nb_bVarEstimator.getDummyPriorOptions(nLags,prior,...
        constant,timeTrend);
    
    % Gibbs sampler
    R                  = R_prior;
    [beta,sigma,yD,pD] = nb_bVarEstimator.nwishartMFGibbs(draws,y,x,H,R_prior,A_OLS,initSigma,...
        a_prior,V_prior_inv,S_prior,v_post,restrictions,thin,burn,waitbar,maxTries,...
        dummyPriorOptions);
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return the mean estimates of unobservables
    yM    = mean(yD,3);
    yMLag = yM(:,numDep+1:numDep*(nLags+1),:);
    X     = [x(nLags+1:end,:),yMLag]; % Exogenous and lags
    X     = kron(eye(numDep),X);
    
    % Return all needed information to do posterior draws
    if nargout > 3
        posterior = struct('type','nwishartMF','betaD',beta,'sigmaD',sigma,'dependent',y,'yD',yD,'pD',pD,...
                           'regressors',x,'H',H,'a_prior',a_prior,'S_prior',S_prior,'v_post',v_post,...
                           'V_prior_inv',V_prior_inv,'restrictions',{restrictions},'R_prior',R_prior,...
                           'maxTries',maxTries,'dummyPriorOptions',dummyPriorOptions);
    end
    
end
    
    
