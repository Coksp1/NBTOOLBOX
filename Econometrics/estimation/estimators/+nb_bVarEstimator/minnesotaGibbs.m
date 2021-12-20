function [beta,sigma] = minnesotaGibbs(draws,y,X,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,restrictions,burn,thin,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.minnesotaGibbs(draws,y,X,initBeta,...
%                initSigma,a_prior,V_prior,S_prior,v_post,restrictions,...
%                burn,thin,waitbar)
%
% Description:
%
% Gibbs sampling from posterior of a B-VAR that implements a independent 
% normal-wishart type prior. The normal part is taken from a minnesota
% style prior on the coefficents of the dynamics.
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

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);

    [numCoeff,nEq] = size(initBeta);
    N              = size(a_prior,1);
    T              = size(y,1);
    if isempty(restrictions)
        XS  = X(1:T,1:numCoeff);
        XS2 = XS'*XS;
    end
    alpha     = nan(N,draws);
    sigma     = nan(nEq,nEq,draws);
    sigma_inv = eye(nEq)/initSigma;
    vec_y     = y(:);
    Ie        = eye(size(S_prior,1));
    for ii = 1:burn
    
        if isempty(restrictions)
            SXTX = kron(sigma_inv,XS2);
            SXTy = kron(sigma_inv,XS)'*vec_y;
        else
            VARIANCE = kron(sigma_inv,eye(T));
            SXT      = X'*VARIANCE;
            SXTX     = SXT*X;
            SXTy     = SXT*vec_y;
        end

        % Posterior of alpha | y, SIGMA^(-1)
        V_prior_inv = eye(N)/V_prior;
        V_post      = eye(N)/(V_prior_inv + SXTX);
        a_post      = V_post*(V_prior_inv*a_prior + SXTy);
        chol_V_post = chol(V_post)';
        alphaI      = a_post + chol_V_post*randn(N,1);
        
        % Posterior of SIGMA|alpha,Data ~ iW(S_post,v_post)
        res         = vec_y - X*alphaI;
        res         = reshape(res,T,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigma_inv   = nb_distribution.wish_rand(S_post_inv,v_post);
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk = 1;
    for ii = 1:draws*thin
    
        % Posterior of alpha | y, SIGMA^(-1)
        if isempty(restrictions)
            SXTX = kron(sigma_inv,XS2);
            SXTy = kron(sigma_inv,XS)'*vec_y;
        else
            VARIANCE = kron(sigma_inv,eye(T));
            SXT      = X'*VARIANCE;
            SXTX     = SXT*X;
            SXTy     = SXT*vec_y;
        end

        V_prior_inv = eye(N)/V_prior;
        V_post      = eye(N)/(V_prior_inv + SXTX);
        a_post      = V_post*(V_prior_inv*a_prior + SXTy);
        chol_V_post = chol(V_post)';
        alphaD      = a_post + chol_V_post*randn(N,1);
        
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
            if isWaitbar
                nb_bVarEstimator.notifyWaitbar(h,burn + kk,note);
            end
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
