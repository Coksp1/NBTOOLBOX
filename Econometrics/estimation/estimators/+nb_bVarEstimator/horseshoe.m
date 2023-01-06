function [beta,sigma,X,posterior] = horseshoe(draws,y,x,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,X,posterior] = nb_bVarEstimator.inwishart(draws,y,x,...
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
    end
    
    if prior.LR || prior.SC || prior.DIO
        error('Cannot apply dummy priors for the prior horseshoe')
    end
    if ~isempty(restrictions)
        % TODO: Add support for this!
        error([mfilename ':: Block exogenous variables cannot be declared with the horseshoe prior.'])
    end 
    
    % Are we dealing with all zero regressors?
    [T,numDep]             = size(y);
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0,restrictions);
    numCoeff               = size(x,2) + constant + timeTrend;

    % add constant and trend
    if isempty(x)
        sizeX = size(y,1);
        x     = zeros(sizeX,0);
    else
        sizeX = size(x,1);
    end
    
    % Add constant if wanted
    if timeTrend == 1 && constant == 0
        trend = 1:sizeX;
        XX    = [trend', x];
    elseif timeTrend == 0 && constant == 1      
        XX = [ones(sizeX,1), x];
    elseif constant == 1 && timeTrend == 1
        trend = 1:sizeX;       
        XX = [ones(sizeX,1), trend, x];
    else
        XX = x;
    end
    
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
    [beta,sigma] = nb_bVarEstimator.horseshoeGibbs(draws,y,XX,A_OLS,initSigma,...
        a_prior,S_prior,v_post,restrictions,thin,prior.burn,waitbar);
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','horseshoe','betaD',beta,'sigmaD',sigma,'dependent',y,...
                           'regressors',XX,'a_prior',a_prior,'S_prior',S_prior,'v_post',v_post,...
                           'restrictions',{restrictions},'thin',thin);
    end
    
end
    
    
