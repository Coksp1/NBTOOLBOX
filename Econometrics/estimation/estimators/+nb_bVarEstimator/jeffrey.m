function [beta,sigma,X,posterior] = jeffrey(draws,y,x,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,x] = nb_bVarEstimator.jeffrey(draws,y,x,constant,...
%                           timeTrend,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using diffuse (Jeffrey) prior.
%
% This code is based the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
        if nargin < 7
            restrictions = [];
            if nargin < 6
                prior = struct('indCovid',[]);
                if nargin < 5
                    timeTrend = 0;
                    if nargin < 4
                        constant = 0;
                    end
                end
            end
        end
    end

    % Are we dealing with all zero regressors?
    [~,numDep]             = size(y);
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0,restrictions);
    
    % Strip observations
    [y,x] = nb_bVarEstimator.stripObservations(prior,y,x);

    % Initialize priors
    %-----------------------
    if isempty(restrictions)
        [initBeta,~,~,~,res,X] = nb_ols(y,x,constant,timeTrend);
    else
        [initBeta,~,~,~,res,X] = nb_olsRestricted(y,x,restrictions,constant,timeTrend);
    end
    [numCoeff,nEq] = size(initBeta);
    a_ols          = initBeta(:);
    T              = size(res,1);
    SSE            = res'*res;
    S_post         = SSE/(T - numCoeff); % Should these be adjusted differently for restricted equations?
    
    % Monte carlo integration
    %------------------------
    if draws > 1
        if ~isempty(restrictions)
            a_ols = a_ols([restrictions{:}]); % Remove zero restricted params
        end
        [beta,sigma] = nb_bVarEstimator.jeffreyMCI(draws,X,T,numCoeff,nEq,...
            S_post,SSE,a_ols,restrictions,waitbar);
    else
        % This is the posterior mode!
        beta  = reshape(a_ols,[numCoeff,nEq]);
        sigma = S_post;
        if ~isempty(restrictions)
            a_ols = a_ols([restrictions{:}]); % Remove zero restricted params
        end
    end
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','jeffrey','betaD',beta,'sigmaD',sigma,...
                           'regressors',X,'SSE',SSE,'a_ols',a_ols,'T',T,...
                           'restrictions',{restrictions});
    end
    
end
