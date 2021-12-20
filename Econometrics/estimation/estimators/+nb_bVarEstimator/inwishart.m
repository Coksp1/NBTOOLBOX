function [beta,sigma,X,posterior] = inwishart(draws,y,x,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,X,posterior] = nb_bVarEstimator.inwishart(draws,y,x,...
%                       constant,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using independent Normal-Wishart prior.
%
% This code is based on the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
% See page 12-13. 
%
% See also the DAG.pdf documentation.
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x neq*nlags + h. Where h
%                  is the exogenous variables of the model.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
    end

    % Are we dealing with all zero regressors?
    [T,numDep]             = size(y);
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0,restrictions);
    numCoeff               = size(x,2) + constant + timeTrend;

    % Initial values for Gibbs
    if isempty(restrictions)
        [A_OLS,~,~,~,r,X] = nb_ols(y,x,constant,timeTrend);
    else
        [A_OLS,~,~,~,r,X] = nb_olsRestricted(y,x,restrictions,constant,timeTrend);
    end
    SSE       = r'*r;
    initSigma = SSE./(T-numCoeff+1);
    
    % Setting up the priors
    a_prior  = zeros(numCoeff*numDep,1);             
    if ~isempty(restrictions)
        restr   = [restrictions{:}];
        a_prior = a_prior(restr);
    end
    V_prior = prior.V_scale*eye(size(a_prior,1));   
    
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    else
        S_scale = 1;
    end
    v_prior = numDep+1;        
    S_prior = S_scale*eye(numDep);     
    
    % Get all the required quantities for the posteriors   
    v_post  = T + v_prior;
    
    if isfield(prior,'thin')
        thin = prior.thin;
    else
        thin = 2;
    end
    
    % Gibbs sampler
    %------------------------
    [beta,sigma] = nb_bVarEstimator.inwishartGibbs(draws,y,X,A_OLS,initSigma,a_prior,V_prior,S_prior,v_post,restrictions,thin,prior.burn,waitbar);
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','inwishart','betaD',beta,'sigmaD',sigma,'dependent',y,...
                           'regressors',X,'a_prior',a_prior,'S_prior',S_prior,'v_post',v_post,...
                           'V_prior',V_prior,'restrictions',{restrictions},'thin',thin);
    end
    
end
    
    
