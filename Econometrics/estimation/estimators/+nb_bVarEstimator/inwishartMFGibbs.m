function [beta,sigma,yDraws,PDraws] = inwishartMFGibbs(draws,y,x,H,R_prior,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,restrictions,thin,burn,waitbar,maxTries)
% Syntax:
%
% [beta,sigma,yDraws,PDraws] = nb_bVarEstimator.inwishartMFGibbs(draws,...
%       y,x,H,R_prior,initBeta,initSigma,a_prior,V_prior,S_prior,...
%       v_post,restrictions,thin,burn,waitbar,maxTries)
%
% Description:
%
% Gibbs sampling from posterior of a mixed frequency or missing observation
% B-VAR that implements a independent normal-wishart type prior. The 
% normal part is set to zero. This method extends 
% nb_bVarEstimator.inwishartGibbs.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);

    % Preallocating
    if ~isempty(restrictions)
        restr      = [restrictions{:}];
        alphaD     = initBeta(:);
        alphaD     = alphaD(restr);
        restricted = true;
    else
        alphaD     = initBeta(:);
        restricted = false;
    end
    alphaB         = alphaD; % Backup of intial values
    nExo           = size(x,2);
    [numCoeff,nEq] = size(initBeta);
    nLags          = (numCoeff - nExo)/nEq;
    numRows        = (nLags - 1)*nEq;
    nStates        = size(H,2);
    T              = size(y,1);
    sigmaD         = initSigma;
    N              = size(a_prior,1);
    sigma          = nan(nEq,nEq,draws);
    Ie             = eye(nEq);
    Ibig           = eye(size(V_prior,1));
    V_prior_inv    = Ibig/V_prior;
    alpha          = zeros(N,draws);
    yDraws         = nan(size(y,1) - nLags,nStates,draws);
    sigmaD_ninv    = Ie/sigmaD;
    alphaR         = zeros(numCoeff*nEq,1);
    yT             = y';
    XT             = x';
    I              = eye(numRows);
    Z              = zeros(numRows,nEq);
    
    nowcast = T - find(~any(isnan(yT),1),1,'last');
    PDraws  = nan(nEq,nEq,nowcast,draws);
    
    for ii = 1:burn
    
        % Posterior y | alpha, SIGMA^(-1)
        [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,sigmaD,nEq,nLags,nExo,restrictions,H,R_prior,yT);
        XS     = [x(nLags+1:end,:),ys(nLags+1:end,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
        ys     = ys(nLags+1:end,1:nEq);
        
        % Expand regressors and remove the variables restricted to be zero
        vec_y = ys(:);
        X     = kron(Ie,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        TS       = size(ys,1);
        VARIANCE = kron(sigmaD_ninv,eye(TS));
        V_post   = Ibig/(V_prior_inv + X'*VARIANCE*X);
        a_post   = V_post*(V_prior_inv*a_prior + X'*VARIANCE*vec_y);
        unstable = true;
        tries    = 0;
        while unstable
            alphaD = a_post + transpose(chol(V_post))*randn(N,1); % Draw of alpha
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
        
        % Posterior of SIGMA|alpha,Data ~ iW(inv(S_post),v_post)
        res         = vec_y - X*alphaD;
        res         = reshape(res,TS,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigmaD_ninv = nb_distribution.wish_rand(S_post_inv,v_post);
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk = 1;
    for ii = 1:draws*thin
    
        % Posterior y | alpha, SIGMA^(-1)
        if rem(ii,thin) == 0 && nowcast
            [~,ys,~,~,~,~,P] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
            PDraws(:,:,:,kk) = P(1:nEq,1:nEq,end-nowcast+1:end);
        else
            [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
        end
        ysAllStates = ys(nLags+1:end,:);
        XS          = [x(nLags+1:end,:),ys(nLags+1:end,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
        ys          = ys(nLags+1:end,1:nEq);
        
        % Expand regressors and remove the variables restricted to be zero
        vec_y = ys(:);
        X     = kron(Ie,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        TS       = size(ys,1);
        VARIANCE = kron(sigmaD_ninv,eye(TS));
        V_post   = Ibig/(V_prior_inv + X'*VARIANCE*X);
        a_post   = V_post*(V_prior_inv*a_prior + X'*VARIANCE*vec_y);
        unstable = true;
        tries    = 0;
        while unstable
            alphaD = a_post + transpose(chol(V_post))*randn(N,1); % Draw of alpha
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
        res           = reshape(res,TS,nEq);
        S_post        = S_prior + res'*res;
        S_post_inv    = Ie/S_post;
        sigmaD_ninv   = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD        = Ie/sigmaD_ninv;% Draw SIGMA
        
        if rem(ii,thin) == 0
            alpha(:,kk)    = alphaD;
            sigma(:,:,kk)  = sigmaD; 
            yDraws(:,:,kk) = ysAllStates;
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
    if restricted
        alphaSub       = alpha;
        alpha          = zeros(length(restr),draws);
        alpha(restr,:) = alphaSub;
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]);
    
end
