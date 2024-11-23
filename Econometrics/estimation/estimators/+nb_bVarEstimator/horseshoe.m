function [beta,sigma,X,posterior] = horseshoe(draws,y,x,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,X,posterior] = nb_bVarEstimator.horseshoe(draws,y,x,...
%                       constant,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using horseshoe prior.
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
% Written by Maximilian Schröder

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
    end
    
    if prior.LR || prior.SC || prior.DIO || prior.SVD
        error('Cannot apply dummy priors for the prior horseshoe')
    end
    if ~isempty(restrictions)
        % TODO: Add support for this!
        error(['Block exogenous variables cannot be declared with the ',...
            'horseshoe prior.'])
    end 
    
    % Are we dealing with all zero regressors?
    [~,numDep]             = size(y);
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0,restrictions);
    numCoeff               = size(x,2) + constant + timeTrend;

    % add constant and trend
    if isempty(x)
        T = size(y,1);
        x = zeros(T,0);
    else
        T = size(x,1);
    end
    
    % Add constant if wanted
    if timeTrend == 1 && constant == 0
        trend = 1:T;
        X     = [trend', x];
    elseif timeTrend == 0 && constant == 1      
        X = [ones(T,1), x];
    elseif constant == 1 && timeTrend == 1
        trend = 1:T;       
        X = [ones(T,1), trend, x];
    else
        X = x;
    end

    % Strip observations
    [y,X] = nb_bVarEstimator.stripObservations(prior,y,X);
    
    % Initial values for Gibbs
    A_RIDGE = reshape((X'*X+0.9*eye(size(X,2)))\(X'*y),size(X,2),size(y,2)); % initialize with Ridge regression
    
    % Setting up the priors
    a_prior  = zeros(numCoeff*numDep,1);             
    if ~isempty(restrictions)
        restr   = [restrictions{:}];
        a_prior = a_prior(restr);
    end   
    
    % Gibbs sampler
    %------------------------
    [beta,sigma] = nb_bVarEstimator.horseshoeGibbs(draws,y,X,A_RIDGE,...
        a_prior,restrictions,prior,waitbar);
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','horseshoe','betaD',beta,'sigmaD',sigma,...
            'dependent',y,'regressors',X,'a_prior',a_prior,'restrictions',...
            {restrictions},'prior',prior);
    end
    
end
    
    
