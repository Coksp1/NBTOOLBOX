function [beta,sigma,X,posterior,pY] = nwishart(draws,y,x,nLags,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% beta = nb_bVarEstimator.nwishart(draws,y,x,nLags,...
%   constant,timeTrend,prior,restrictions,waitbar)
%
% [beta,sigma,X,posterior,pY] = nb_bVarEstimator.nwishart(draws,y,x,nLags,...
% 	constant,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using Normal-Wishart prior.
%
% This code is based on code from a paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
%
% See page 9 of Koop and Korobilis (2009)
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x neq*nlags + h. Where h
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
%                Caution : If nargout == 1, this output is the marginal
%                          likelihood.
%
% - sigma      : A neq x neq x draws matrix with the posterior variance of 
%                the the estimated coefficients. 
%
% - X          : Regressors including constant and time-trend.
% 
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% - pY         : Log marginal likelihood.
%
% See also
% nb_bVarEstimator.estimate, nb_var, nb_bVarEstimator.logMarginalLikelihood
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
    end
    if ~isempty(restrictions)
        error('Block exogenous variables cannot be declared with the nwishart prior.')
    end
    
    % Are we dealing with all zero regressors?
    [T,numDep] = size(y);
    [x,indZR]  = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0);
    
    % Append deterministic regressors
    if timeTrend
        trend = 1:T;
        x     = [trend', x];
    end
    if constant        
        x = [ones(T,1), x];
    end
    numCoeff = size(x,2);

    % Prior on vec(beta) ~ N(vec(A_prior), Sigma x V_prior)
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

    [A_OLS,~,~,~,r,X] = nb_ols(yOLS,xOLS);
    SSE               = r'*r;
    A_prior           = zeros(numCoeff,numDep); 
    a_ols             = A_OLS(:);
    v_prior           = prior.V_scale*ones(size(a_ols,1),1);    
    
    % Strip observations
    [y,x,T] = nb_bVarEstimator.stripObservations(prior,y,x);

    % Prior on Sigma ~ IW(S_prior,v_prior,)
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    else
        S_scale = 1;
    end
    s_prior = S_scale*ones(1,numDep);
    S_prior = diag(s_prior); 
    
    % Posteriors (here we assume a normal-wishart type prior)
    I           = eye(numCoeff);
    xx          = x'*x;
    V_prior_inv = (1/prior.V_scale)*I;
    A_post      = (xx + V_prior_inv)\(x'*y + V_prior_inv*A_prior);
    
    % Posterior Sigma | Y ~ IW(S_post,v_post)
    S_post      = SSE + S_prior + A_OLS'*xx*A_OLS + A_prior'*V_prior_inv*A_prior - A_post'*(V_prior_inv + xx)*A_post;
    v_post      = T + numDep - nLags + 2;
    
    % Posterior vec(beta) | sigma, Y ~ N(a_post,kron(sigma,V_post))
    a_post = A_post(:);
    V_post = (xx + V_prior_inv)\I;
    
    if nargout == 1
        % In this case we report the marginal likelihood p(Y)
        eps  = y - x*A_post;
        beta = logMarginalLikelihood(prior,T,numDep,y,x,v_post - T + nLags,...
            A_prior,A_post,s_prior,v_prior(1:numCoeff),eps);
    else
    
        % Simulate from posterior using Monte carlo integration
        if draws > 1
            [beta,sigma] = nb_bVarEstimator.nwishartMCI(draws,A_OLS,...
                S_post,a_post,V_post,S_post,v_post,restrictions,waitbar);
        else
            beta  = A_post;
            sigma = S_post/v_post;
        end

        % Return all needed information to do posterior draws
        if nargout > 3
            posterior = struct('type','nwishart','betaD',beta,'sigmaD',sigma,'dependent',y,...
                               'regressors',X,'a_post',a_post,'S_post',S_post,'v_post',v_post,...
                               'V_post',V_post,'restrictions',{restrictions});
            if nargout > 4
                eps = y - x*A_post;
                pY  = logMarginalLikelihood(prior,T,numDep,y,x,...
                    v_post - T + nLags,A_prior,A_post,s_prior,v_prior(1:numCoeff),eps);
            end
        end
        
        % Expand to include all zero regressors
        if any(~indZR)
            beta = nb_bVarEstimator.expandZR(beta,indZR); 
        end
        
    end
    
end

%==========================================================================
function pY = logMarginalLikelihood(prior,Traw,numDep,y,x,d,A_prior,A_post,s_prior,v_prior,eps)

    xx = x'*x;
    pY = nb_bVarEstimator.logMarginalLikelihood(Traw,numDep,d,xx,A_prior,A_post,s_prior,v_prior,eps);
    if prior.LR || prior.SC || prior.DIO
        elem = 0;
        if prior.LR || prior.SC
            elem = elem + numDep;
        end
        if prior.DIO
            elem = elem + 1;
        end
        yd   = y(end-elem+1:end,:);
        xd   = x(end-elem+1:end,:);
        norm = nb_bVarEstimator.dummyNormalizationConstant(yd,xd,d,A_prior,s_prior,v_prior);
        pY   = pY - norm;
    end
    if prior.SVD
        % Correct for stocastic-volatility-dummy prior
        T = size(y,1);
        if prior.LR || prior.SC
            T = T - numDep;
        end
        if prior.DIO
            T = T - 1;
        end
        invWeights = nb_bVarEstimator.constructInvWeights(prior,T);
        pY         = pY - size(y,2)*sum(log(invWeights));
    end
        
end
    
    
