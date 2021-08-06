function [beta,sigma] = minnesotaMCI(draws,y,X,initBeta,initSigma,a_prior,V_prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.minnesotaMCI(draws,y,X,initBeta,...
%                        initSigma,a_prior,V_prior,restrictions,waitbar)
%
% Description:
%
% Monte carlo integration of B-VAR with minnesota prior.
% 
% This code is based on the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
% See page 7 of Koop and Korobilis (2009)
%
% Input:
% 
% See nb_bVarEstimator.minnesota
% 
% Output:
% 
% See nb_bVarEstimator.minnesota
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [numCoeff,nEq] = size(initBeta);
    N              = size(a_prior,1);
    T              = size(y,1);
    alpha          = nan(N,draws);
    sigma_inv      = eye(nEq)/initSigma;
    if isempty(restrictions)
        X    = X(1:T,1:numCoeff);
        XTX  = X'*X;
        SXTX = kron(sigma_inv,XTX);
        SXTy = kron(sigma_inv,X)'*y(:);
    else
        VARIANCE = kron(sigma_inv,eye(T));
        SXT      = X'*VARIANCE;
        SXTX     = SXT*X;
        SXTy     = SXT*y(:);
    end
    
    % Posterior of alpha | y, SIGMA^(-1)
    V_prior_inv = eye(N)/V_prior;
    V_post      = eye(N)/(V_prior_inv + SXTX);
    a_post      = V_post*(V_prior_inv*a_prior + SXTy);
    chol_V_post = chol(V_post)';
    for ii = 1:draws
        alpha(:,ii) = a_post + chol_V_post*randn(N,1); 
    end
    
    % Expand to include zero restrictions
    if ~isempty(restrictions)
        restrictions          = [restrictions{:}];
        alphaSub              = alpha;
        alpha                 = zeros(length(restrictions),draws);
        alpha(restrictions,:) = alphaSub;
    end
    
    % Reshape to matrix form
    sigma = initSigma(:,:,ones(1,draws)); % A know matrix given by the prior
    beta  = reshape(alpha,[numCoeff,nEq,draws]); 
    
end
