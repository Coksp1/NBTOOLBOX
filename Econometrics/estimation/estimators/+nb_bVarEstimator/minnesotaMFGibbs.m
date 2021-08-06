function [beta,sigma,yDraws] = minnesotaMFGibbs(draws,y,x,H,R_prior,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,restrictions,burn,thin,waitbar,maxTries)
% Syntax:
%
% [beta,sigma,yDraws] = nb_bVarEstimator.minnesotaMFGibbs(draws,y,x,H,...
%             R_prior,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,...
%             restrictions,burn,thin,waitbar,maxTries)
%
% Description:
%
% Gibbs sampling from posterior of a mixed frequency or missing observation
% B-VAR that implements a independent normal-wishart type prior. The 
% normal part is taken from a minnesota style prior on the coefficents of 
% the dynamics. This method extends nb_bVarEstimator.minnesotaGibbs
%
% Input:
% 
% See nb_bVarEstimator.minnesotaMF
% 
% Output:
% 
% See nb_bVarEstimator.minnesotaMF
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);
    
    [numCoeff,nEq] = size(initBeta);
    alphaR         = initBeta(:);
    if ~isempty(restrictions)
        restr      = [restrictions{:}];
        alphaD     = initBeta(:);
        alphaD     = alphaD(restr);
        restricted = true;
    else
        alphaD     = initBeta(:);
        restricted = false;
    end
    alphaB    = alphaD; % Backup of intial values
    nExo      = size(x,2);
    nLags     = (numCoeff - nExo)/nEq;
    numRows   = (nLags - 1)*nEq;
    nStates   = size(H,2);
    N         = size(a_prior,1);
    T         = size(y,1);
    alpha     = nan(N,draws);
    sigma     = nan(nEq,nEq,draws);
    Isigma    = eye(nEq);
    sigma_inv = Isigma/initSigma;
    sigmaD    = initSigma;
    yDraws    = nan(size(y,1),nStates,draws);
    yT        = y';
    XT        = x';
    Ie        = eye(size(S_prior,1));
    I         = eye(numRows);
    Z         = zeros(numRows,nEq);
    for ii = 1:burn
    
        % Posterior y | alpha, SIGMA^(-1)
        [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,sigmaD,nEq,nLags,nExo,restrictions,H,R_prior);
        XS     = [x,ys(:,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
        ys     = ys(:,1:nEq);
        
        % Expand regressors and remove the variables restricted to be zero
        X = kron(Isigma,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        vec_y = ys(:);
        if restricted
            VARIANCE = kron(sigma_inv,eye(T));
            SXT      = X'*VARIANCE;
            SXTX     = SXT*X;
            SXTy     = SXT*vec_y;
        else
            XS2  = XS'*XS;
            SXTX = kron(sigma_inv,XS2);
            SXTy = kron(sigma_inv,XS)'*vec_y;
        end

        V_prior_inv = eye(N)/V_prior;
        V_post      = eye(N)/(V_prior_inv + SXTX);
        a_post      = V_post*(V_prior_inv*a_prior + SXTy);
        chol_V_post = chol(V_post)';
        unstable    = true;
        tries       = 0;
        while unstable
            alphaD  = a_post + chol_V_post*randn(N,1);
            if restricted
                alphaR(restr) = alphaD;
            else
                alphaR = alphaD;
            end
            ALPHAD  = reshape(alphaR,[numCoeff,nEq])';
            ALPHAD  = ALPHAD(:,nExo+1:end);
            A       = [ALPHAD; I,Z];
            [~,~,m] = nb_calcRoots(A);
            if all(m < 1)
                unstable = false; 
            end
            tries = tries + 1;
            if tries > maxTries
                % Give up an use last value of alpha
                break
            end
        end
        
        % Posterior of SIGMA|alpha,Data ~ iW(S_post,v_post)
        res         = vec_y - X*alphaD;
        res         = reshape(res,T,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigma_inv   = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD      = Ie/sigma_inv; % Draw SIGMA
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk = 1;
    for ii = 1:draws*thin
    
        % Posterior y | alpha, SIGMA^(-1)
        [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,sigmaD,nEq,nLags,nExo,restrictions,H,R_prior);
        XS     = [x,ys(:,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
        ysDep  = ys(:,1:nEq);
        
        % Expand regressors and remove the variables restricted to be zero
        X = kron(Isigma,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        vec_y = ysDep(:);
        if restricted
            VARIANCE = kron(sigma_inv,eye(T));
            SXT      = X'*VARIANCE;
            SXTX     = SXT*X;
            SXTy     = SXT*vec_y;
        else
            XS2  = XS'*XS;
            SXTX = kron(sigma_inv,XS2);
            SXTy = kron(sigma_inv,XS)'*vec_y;
        end

        V_prior_inv = eye(N)/V_prior;
        V_post      = eye(N)/(V_prior_inv + SXTX);
        a_post      = V_post*(V_prior_inv*a_prior + SXTy);
        chol_V_post = chol(V_post)';
        unstable    = true;
        tries       = 0;
        while unstable
            alphaD = a_post + chol_V_post*randn(N,1);
            if restricted
                alphaR(restr) = alphaD;
            else
                alphaR = alphaD;
            end
            ALPHAD  = reshape(alphaR,[numCoeff,nEq])';
            ALPHAD  = ALPHAD(:,nExo+1:end);
            A       = [ALPHAD; I,Z];
            [~,~,m] = nb_calcRoots(A);
            if all(m < 1)
                unstable = false; 
            end
            tries = tries + 1;
            if tries > maxTries
                % Give up an use last value of alpha
                if kk > 1
                    alphaD = alphaB;
                else
                    alphaD = alpha(:,kk-1);
                end
                break
            end
        end
        
        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        res           = vec_y - X*alphaD;
        res           = reshape(res,T,nEq);
        S_post        = S_prior + res'*res;
        S_post_inv    = Ie/S_post;
        sigmaD_ninv   = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD        = Ie/sigmaD_ninv;% Draw SIGMA
        
        if rem(ii,thin) == 0
            alpha(:,kk)    = alphaD;
            sigma(:,:,kk)  = sigmaD; 
            yDraws(:,:,kk) = ys;
            kk             = kk + 1;
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
        alphaSub       = alpha;
        alpha          = zeros(length(restr),draws);
        alpha(restr,:) = alphaSub;
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]); 
    
end
