function [beta,sigma] = horseshoeGibbs(draws,y,X,initBeta,initSigma,a_prior,S_prior,v_post,restrictions,thin,burn,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.inwishartGibbs(draws,y,X,initBeta,...
%                   initSigma,a_prior,S_prior,v_post,...
%                   restrictions,thin,burn,waitbar)
%
% Description:
%
% Gibbs sampler draws of B-VAR with horseshoe prior.
% 
% Input:
% 
% See nb_bVarEstimator.inwishart
% 
% Output:
% 
% See nb_bVarEstimator.inwishart
%
% Written by Maximilian Schröder

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 12
        waitbar = false;
        if nargin < 11
            burn = 10;
        end
    end

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);

    % Preallocating
    T              = size(y,1);
    sigmaD         = initSigma;
    [numCoeff,nEq] = size(initBeta);
    PAI            = initBeta;
    N              = size(a_prior,1);
    sigma          = nan(nEq,nEq,draws);
    Ie             = eye(nEq);
    vec_y          = y(:);
    alpha          = zeros(N,draws);
    
    n = size(y,2); 
    K = size(X,2);
    
    [L,D]     = ldl(sigmaD); 
    A_        = L;
    sqrt_ht   = repmat(sqrt(diag(D)'),T,1); 
    
    %%%%%%%%% ToDos
    %%%% * need to move prior settings up (global local shrinkage)
    %%%% * test variance terms (i.e. scaling at different stages of algorithm) Chan vs. HS
    %%%% * check ordering/mapping of outputs 
    %%%% * test coefficient accuracy (simulation/MC study)
    %%%% * remove clutter
    %%%% * add comments and notes on sampler
    %%%% * need to check and adjust other higher level structure. talk to Kenneth
    
    lambda = 0.1*ones(K,n);
    tau    = ones(n,1)*0.1;
    for ii = 1:burn

        % Sample VAR coefficients
        [PAI, lambda, tau] = nb_bVarEstimator.CCCMSampler(y,X,n,K,[],A_,sqrt_ht,PAI,lambda,tau);

        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        yhat_       = X*PAI;
        res         = vec_y - yhat_(:);
        res         = reshape(res,T,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigmaD_ninv = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD      = Ie/sigmaD_ninv;% Draw SIGMA
        [L,D]       = ldl(sigmaD); 
        A_          = inv(L);
        sqrt_ht     = repmat(sqrt(diag(D)'),T,1); 
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk = 1;
    for ii = 1:draws*thin
    
        % Sample VAR coefficients
        [PAI, lambda, tau] = nb_bVarEstimator.CCCMSampler(y,X,n,K,[],A_,sqrt_ht,PAI,lambda,tau);
        
        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        yhat_       = X*PAI;
        res         = vec_y - yhat_(:);
        res         = reshape(res,T,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigmaD_ninv = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD      = Ie/sigmaD_ninv;% Draw SIGMA
        [L,D]       = ldl(sigmaD); 
        A_          = inv(L);
        sqrt_ht     = repmat(sqrt(diag(D)'),T,1);
        
        if rem(ii,thin) == 0
            alpha(:,kk)   = PAI(:);
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
