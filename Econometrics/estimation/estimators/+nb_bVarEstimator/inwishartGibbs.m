function [beta,sigma] = inwishartGibbs(draws,y,X,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,restrictions,thin,burn,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.inwishartGibbs(draws,y,X,initBeta,...
%                   initSigma,a_prior,V_prior,S_prior,v_post,...
%                   restrictions,thin,burn,waitbar)
%
% Description:
%
% Gibbs sampler draws of B-VAR with independent Normal-Wishart prior.
% 
% This code is based the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
% See page 12-13.
%
% See also the DAG.pdf documentation.
%
% Input:
% 
% See nb_bVarEstimator.inwishart
% 
% Output:
% 
% See nb_bVarEstimator.inwishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 13
        waitbar = false;
        if nargin<12
            burn = 10;
        end
    end

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);

    % Preallocating
    T              = size(y,1);
    sigmaD         = initSigma;
    [numCoeff,nEq] = size(initBeta);
    N              = size(a_prior,1);
    sigma          = nan(nEq,nEq,draws);
    Ie             = eye(nEq);
    vec_y          = y(:);
    Ibig           = eye(size(V_prior,1));
    V_prior_inv    = Ibig/V_prior;
    alpha          = zeros(N,draws);
    sigmaD_ninv    = Ie/sigmaD;
    
    for ii = 1:burn
    
        % Posterior of alpha | y, SIGMA^(-1)
        VARIANCE = kron(sigmaD_ninv,eye(T));
        V_post   = Ibig/(V_prior_inv + X'*VARIANCE*X);
        a_post   = V_post*(V_prior_inv*a_prior + X'*VARIANCE*vec_y);
        alphaD   = a_post + transpose(nb_chol(V_post,'cov'))*randn(N,1); % Draw of alpha
        
        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        res         = vec_y - X*alphaD;
        res         = reshape(res,T,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigmaD_ninv = nb_distribution.wish_rand(S_post_inv,v_post);
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk = 1;
    for ii = 1:draws*thin
    
        % Posterior of alpha | y, SIGMA^(-1)
        VARIANCE = kron(sigmaD_ninv,eye(T));
        V_post   = Ibig/(V_prior_inv + X'*VARIANCE*X);
        a_post   = V_post*(V_prior_inv*a_prior + X'*VARIANCE*vec_y);
        alphaD   = a_post + transpose(chol(V_post))*randn(N,1); % Draw of alpha
        
        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        res           = vec_y - X*alphaD;
        res           = reshape(res,T,nEq);
        S_post        = S_prior + res'*res;
        S_post_inv    = Ie/S_post;
        sigmaD_ninv   = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD        = Ie/sigmaD_ninv;% Draw SIGMA
        
        if rem(ii,thin) == 0
            alpha(:,kk)   = alphaD;
            sigma(:,:,kk) = sigmaD; 
            kk            = kk + 1;
        end
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,burn + kk,note);
        end
        
    end
    
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(h);
    end
    
    % Expand to include zero restrictions
    if ~isempty(restrictions)
        restrictions          = [restrictions{:}];
        alphaSub              = alpha;
        alpha                 = zeros(length(restrictions),draws);
        alpha(restrictions,:) = alphaSub;
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]);
    
end
