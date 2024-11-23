function [beta,sigma,yDraws,PDraws] = minnesotaMFGibbs(draws,y,x,H,R_prior,initBeta,...
    initSigma,a_prior,V_prior,S_prior,v_post,restrictions,burn,thin,waitbar,maxTries,dummyPriorOptions)
% Syntax:
%
% [beta,sigma,yDraws,PDraws] = nb_bVarEstimator.minnesotaMFGibbs(draws,...
%       y,x,H,R_prior,initBeta,initSigma,a_prior,V_prior,S_prior,v_post,...
%       restrictions,burn,thin,waitbar,maxTries,dummyPriorOptions)
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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    yDraws    = nan(size(y,1) - nLags,nStates,draws);
    yT        = y';
    XT        = x';
    Ie        = eye(size(S_prior,1));
    I         = eye(numRows);
    Z         = zeros(numRows,nEq);
    
    % Do we handle a model in levels?
    if ~isempty(dummyPriorOptions)
        nonStationary = dummyPriorOptions.prior.nonStationary;
    else
        nonStationary = false;
    end
    nowcast = T - find(~any(isnan(yT),1),1,'last');
    PDraws  = nan(nEq,nEq,nowcast,draws);
    
    for ii = 1:burn
    
        % Posterior y | alpha, SIGMA^(-1)
        [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,sigmaD,nEq,nLags,nExo,restrictions,H,R_prior,yT);
        
        % Add dummy priors
        if ~isempty(dummyPriorOptions)
            % Here we remove the contant term as it is treated in a 
            % special way in the dummy priors!
            ysFull  = ys(:,1:nEq);
            XSFull  = [x(:,dummyPriorOptions.constant+1:end),ys(:,nEq+1:nEq*(nLags+1))];
            XS      = XSFull(nLags+1:end,:); 
            ys      = ys(nLags+1:end,1:nEq);
            [ys,XS] = nb_bVarEstimator.applyDummyPrior(dummyPriorOptions,ys,XS,ysFull,XSFull);
        else
            XS = [x(nLags+1:end,:),ys(nLags+1:end,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
            ys = ys(nLags+1:end,1:nEq);
        end
        
        % Expand regressors and remove the variables restricted to be zero
        X = kron(Isigma,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        vec_y = ys(:);
        TS    = size(ys,1);
        if restricted
            VARIANCE = kron(sigma_inv,eye(TS));
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
            if nonStationary
                break
            end
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
        res         = reshape(res,TS,nEq);
        S_post      = S_prior + res'*res;
        S_post_inv  = Ie/S_post;
        sigma_inv   = nb_distribution.wish_rand(S_post_inv,v_post);
        sigmaD      = Ie/sigma_inv; % Draw SIGMA
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk     = 1;
    alphaB = alphaD; % Backup of to last value of burn in
    for ii = 1:draws*thin
    
        % Posterior y | alpha, SIGMA^(-1)
        if rem(ii,thin) == 0 && nowcast
            [~,ys,~,~,~,~,P] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
            PDraws(:,:,:,kk) = P(1:nEq,1:nEq,end-nowcast+1:end);
        else
            [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
        end
        
        % Add dummy priors
        ysAllStates = ys(nLags+1:end,:);
        if ~isempty(dummyPriorOptions)
            % Here we remove the contant term as it is treated in a 
            % special way in the dummy priors!
            ysFull  = ys(:,1:nEq);
            XSFull  = [x(:,dummyPriorOptions.constant+1:end),ys(:,nEq+1:nEq*(nLags+1))];
            XS      = XSFull(nLags+1:end,:); 
            ys      = ys(nLags+1:end,1:nEq);
            [ys,XS] = nb_bVarEstimator.applyDummyPrior(dummyPriorOptions,ys,XS,ysFull,XSFull);
        else
            XS = [x(nLags+1:end,:),ys(nLags+1:end,nEq+1:nEq*(nLags+1))]; % Exogenous and lags
            ys = ys(nLags+1:end,1:nEq);
        end
        
        % Expand regressors and remove the variables restricted to be zero
        X = kron(Isigma,XS);
        if restricted
            X = X(:,restr);
        end
        
        % Posterior of alpha | y, SIGMA^(-1)
        vec_y = ys(:);
        TS    = size(ys,1);
        if restricted
            VARIANCE = kron(sigma_inv,eye(TS));
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
            if nonStationary
                break
            end
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
                    alphaD = alpha(:,kk-1);
                else
                    alphaD = alphaB;
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
    if ~isempty(restrictions)
        alphaSub       = alpha;
        alpha          = zeros(length(restr),draws);
        alpha(restr,:) = alphaSub;
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]); 
    
end
