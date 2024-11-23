function [beta,sigma,yDraws,PDraws] = nwishartMFGibbs(draws,y,x,H,R_prior,initBeta,initSigma,...
    a_prior,V_prior_inv,S_prior,v_post,restrictions,thin,burn,waitbar,maxTries,dummyPriorOptions)
% Syntax:
%
% [beta,sigma,yDraws,PDraws] = nb_bVarEstimator.nwishartMFGibbs(draws,...
%        y,x,H,R_prior,initBeta,initSigma,a_prior,V_prior_inv,S_prior,...
%        v_post,restrictions,thin,burn,waitbar,maxTries,...
%        dummyPriorOptions)
%
% Description:
%
% Gibbs sampling from a missing observation or mixed frequency B-VAR model
% using a normal wishart prior.
%
% Input:
% 
% See nb_bVarEstimator.nwishart
% 
% Output:
% 
% See nb_bVarEstimator.nwishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 17
        dummyPriorOptions = [];
    end

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);
    [numCoeff,nEq]     = size(initBeta);
    
    % Setting up stuff
    a_prior_p = a_prior;
    A_prior   = reshape(a_prior_p,[numCoeff,nEq]);% Reshape to matrix form
    nExo      = size(x,2);
    nLags     = (numCoeff - nExo)/nEq;
    numRows   = (nLags - 1)*nEq;
    nStates   = size(H,2);
    N         = size(a_prior,1);
    alpha     = nan(N,draws);
    sigma     = nan(nEq,nEq,draws);
    Isigma    = eye(nEq);
    alphaD    = initBeta(:);
    sigmaD    = initSigma;
    yDraws    = nan(size(y,1) - nLags,nStates,draws);
    yT        = y';
    XT        = x';
    IVe       = eye(size(a_prior,1));
    
    % Do we handle a model in levels?
    if ~isempty(dummyPriorOptions)
        nonStationary = dummyPriorOptions.prior.nonStationary;
    else
        nonStationary = false;
    end
    if nonStationary
        tries = 0;
    end
    nowcast = size(yT,2) - find(~any(isnan(yT),1),1,'last');
    PDraws  = nan(nEq,nEq,nowcast,draws);
    
    % Do the burn in
    V_prior_big_inv = kron(eye(nEq),V_prior_inv);
    for ii = 1:burn
    
        % Posterior y | alpha, SIGMA^(-1)
        try
            [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,sigmaD,nEq,nLags,nExo,restrictions,H,R_prior,yT);
        catch Err
            if nonStationary
                if tries > maxTries
                    rethrow(Err)
                end
                alphaD = a_post + chol_COV*randn(N,1);  % Draw alpha
                continue
            else
                rethrow(Err)
            end
        end
            
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
        
        % Expand regressors
        X = kron(Isigma,XS);
        
        % Get mean conditional on data 
        vec_y    = ys(:);
        xx       = XS'*XS;
        XX       = X'*X;
        a_ols    = XX\(X'*vec_y);
        V_post   = IVe/(V_prior_big_inv + XX);
        a_post   = V_post*(V_prior_big_inv*a_prior + XX*a_ols);
        a_post_p = a_post; 
        a_ols_p  = a_ols;
        
        % Reshape to matrix form
        A_post = reshape(a_post_p,[numCoeff,nEq]);
        A_OLS  = reshape(a_ols_p,[numCoeff,nEq]);
        r      = ys - XS*A_OLS;
        S_data = r'*r;
        
        % This is the covariance for the posterior density of alpha
        sigmaBig = kron(sigmaD,eye(numCoeff));
        COV      = V_post*sigmaBig;
        [vv,dd]  = eig(COV);
        chol_COV = real(vv*sqrt(dd));
        
        % Posterior of alpha|SIGMA,Data ~ Normal
        unstable = true;
        tries    = 0;
        while unstable
            alphaD = a_post + chol_COV*randn(N,1);  % Draw alpha
            if nonStationary
                break
            end
            alphaT  = alphaD;
            ALPHAD  = reshape(alphaT,[numCoeff,nEq])';
            ALPHAD  = ALPHAD(:,nExo+1:end);
            A       = [ALPHAD;eye(numRows),zeros(numRows,nEq)];
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
        
        % Posterior of SIGMA|alpha,Data ~ IW(S_post,v_post)
        S_post = S_data + S_prior + A_OLS'*xx*A_OLS + A_prior'*V_prior_inv*A_prior - A_post'*(V_prior_inv + xx)*A_post;
        sigmaD = nb_distribution.invwish_rand(S_post,v_post,'covrepair');
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    kk     = 1;
    alphaB = alphaD; % Backup of to last value of burn in
    for ii = 1:draws*thin
    
        % Posterior y | alpha, SIGMA^(-1)
        try
            if rem(ii,thin) == 0 && nowcast
                [~,ys,~,~,~,~,P] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
                PDraws(:,:,:,kk) = P(1:nEq,1:nEq,end-nowcast+1:end);
            else
                [~,ys] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,yT,XT,alphaD,initSigma,nEq,nLags,nExo,restrictions,H,R_prior,yT);
            end
        catch Err
            if nonStationary
                if tries > maxTries
                    rethrow(Err)
                end
                alphaD = a_post + chol_COV*randn(N,1);  % Draw alpha
                continue
            else
                rethrow(Err)
            end
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
        
        % Get mean conditional on data 
        vec_y    = ys(:);
        xx       = XS'*XS;
        XX       = X'*X;
        a_ols    = XX\(X'*vec_y);
        V_post   = IVe/(V_prior_big_inv + XX);
        a_post   = V_post*(V_prior_big_inv*a_prior + XX*a_ols);
        a_post_p = a_post; 
        a_ols_p  = a_ols;
        
        % Reshape to matrix form
        A_post = reshape(a_post_p,[numCoeff,nEq]);
        A_OLS  = reshape(a_ols_p,[numCoeff,nEq]);
        r      = ys - XS*A_OLS;
        S_data = r'*r;
        
        % This is the covariance for the posterior density of alpha
        sigmaBig = kron(sigmaD,eye(numCoeff));
        COV      = V_post*sigmaBig;
        [vv,dd]  = eig(COV);
        chol_COV = real(vv*sqrt(dd));
        
        % Posterior of alpha|SIGMA,Data ~ Normal
        unstable = true;
        tries    = 0;
        while unstable
            alphaD  = a_post + chol_COV*randn(N,1);  % Draw alpha
            if nonStationary
                break
            end
            alphaT  = alphaD;
            ALPHAD  = reshape(alphaT,[numCoeff,nEq])';
            ALPHAD  = ALPHAD(:,nExo+1:end);
            A       = [ALPHAD;eye(numRows),zeros(numRows,nEq)];
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
        
        % Posterior of SIGMA|alpha,Data ~ iW(S_post,v_post)
        S_post = S_data + S_prior + A_OLS'*xx*A_OLS + A_prior'*V_prior_inv*A_prior - A_post'*(V_prior_inv + xx)*A_post;
        sigmaD = nb_distribution.invwish_rand(S_post,v_post,'covrepair');
        
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
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]); 
    
end
