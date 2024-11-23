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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
    end
    
    if prior.LR || prior.SC || prior.DIO || prior.SVD
        error('Cannot apply dummy priors for the prior inwishart')
    end

    % Add constant if wanted
    [T,numDep] = size(y);
    if timeTrend == 1 && constant == 0
        trend = 1:T;
        x     = [trend', x];
    elseif timeTrend == 0 && constant == 1      
        x = [ones(T,1), x];
    elseif constant == 1 && timeTrend == 1
        trend = 1:T;       
        x = [ones(T,1), trend, x];
    end
    
    % Are we dealing with all zero regressors?
    [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,0,0,numDep,0,restrictions);
    numCoeff               = size(x,2);

    % Initial values for Gibbs
    TrawOLS = T;
    if isfield(prior,'LR')
        % We don't want the dummy observation of the long run prior mess
        % up the OLS estimation itself, so here we remove the dummy
        % observation temporarily
        if prior.LR || prior.SC 
            TrawOLS = TrawOLS - numDep;
        end
        if prior.DIO
            TrawOLS = TrawOLS - 1;
        end
        if prior.SVD
            TrawOLS = min(TrawOLS,prior.obsSVD - 1);
        end
    end

    yOLS = y(1:TrawOLS,:);
    xOLS = x(1:TrawOLS,:);
    if ~isempty(prior.indCovid)
        yOLS = yOLS(prior.indCovid,:);
        xOLS = xOLS(prior.indCovid,:);
    end

    if isempty(restrictions)
        [A_OLS,~,~,~,r] = nb_ols(yOLS,xOLS,0,0);
    else
        [A_OLS,~,~,~,r] = nb_olsRestricted(yOLS,xOLS,...
            restrictions,0,0);
    end
    SSE       = r'*r;
    initSigma = SSE./(size(r,1)-numCoeff+1);
    
    % Strip observations
    [y,x,T] = nb_bVarEstimator.stripObservations(prior,y,x);

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

    % Expand regressors and remove the variables 
    % restricted to be zero
    X = kron(eye(numDep),x);
    if ~isempty(restrictions)
        X = X(:,restr);
    end
    
    % Gibbs sampler
    %------------------------
    [beta,sigma] = nb_bVarEstimator.inwishartGibbs(draws,y,X,A_OLS,...
        initSigma,a_prior,V_prior,S_prior,v_post,restrictions,thin,prior.burn,waitbar);
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','inwishart','betaD',beta,'sigmaD',sigma,...
            'dependent',y,'regressors',X,'a_prior',a_prior,'S_prior',S_prior,...
            'v_post',v_post,'V_prior',V_prior,'restrictions',{restrictions},'thin',thin);
    end
    
end
    
    
