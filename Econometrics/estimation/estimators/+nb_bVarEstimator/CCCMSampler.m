function [PAI,A_,lambda,tau, sigma_sq, nu, xi] = CCCMSampler(Y,X,N,K,~,A_,sig_sq,PAI,lambda,tau,nu,xi,type)
% Syntax:
%
% [PAI,lambda,tau] = nb_bVarEstimator.CCCMSampler(Y,X,N,K,~,A_,sqrt_ht,
%       PAI,lambda,tau)
%
% Description:
%
% Performs a draw from the conditional posterior of the VAR conditional
% mean coefficients by using the triangular algorithm. The
% triangularization achieves computation gains of order N^2 where N is the
% number of variables in the VAR. Algorithm developed in 
% Carriero, Chan, Clark, and Marcellino (2021), Corrigendum to "Large 
% Vector Autoregressions with stochastic volatility and non-conjugate 
% priors."
%
% The model is:
%
%     Y(t) = Pai(L)Y(t-1) + v(t); Y(t) is Nx1; t=1,...,T, L=1,...,p.
%     v(t) = inv(A)*(LAMBDA(t)^0.5)*e(t); e(t) ~ N(0,I);
%                _                                         _
%               |    1          0       0       ...      0  |
%               |  A(2,1)       1       0       ...      0  |
%      A =      |  A(3,1)     A(3,2)    1       ...      0  |
%               |   ...        ...     ...      ...     ... |
%               |_ A(N,1)      ...     ...   A(N,N-1)    1 _|
%
%     Lambda(t)^0.5 = diag[sqrt_h(1,t)  , .... , sqrt_h(N,t)]; 
% 
% Input:
% 
% - Y         : (TxN) matrix of data appearing on the LHS of the VAR
%
% - X         : (TxK) matrix of data appearing on the RHS of the VAR. The 
%               matrix needs to be ordered as: [1, y(t-1), y(t-2),..., y(t-p)]
%
% - N         : scalar, #of variables in VAR 
%
% - K         : scalar, #of regressors (=N*p+1) 
%
% - T         : scalar, #of observations
% 
% - invA_     : (NxN) inverse of lower triangular covariance matrix A
%
% - sqrt_ht   : (TxN) time series of diagonal elements of volatility 
%               matrix. For a homosckedastic system, with Sigma the error 
%               variance, one can perform the LDL decomposition (command 
%               [L,D]  =LDL(Sigma)) and set inv_A=L and sqrt_ht = 
%               repmat(sqrt(diag(D)'),T,1).   
%
% Output:
% 
% - One draw from (PAI|A,Lambda,data). PAI=[Pai(0), Pai(1), ..., Pai(p)].
%
% See also:
% nb_bVarEstimator.horseshoe, nb_bVarEstimator.horseshoePrior
%
% Written by Carriero, Chan, Clark, and Marcellino (2021)
% Adjusted by Maximilian Schröder

 R = (K-1)/N;        % back out number of lags
% 
% % Copyright (c) 2024, Kenneth Sæterhagen Paulsen
%     sigma_sq = zeros(N,1);
PAI_old = PAI;
sigsq_old = sig_sq;
%     for j=1:N
% 
%         % select coefficients of equation j to remove from the LHS
%         PAI(:,j) = zeros(K,1); 
% 
%         % build model
%         %lambda_ = vec(sqrt_ht(:,j:N));
%         Y_j     = vec((Y-X*PAI)*A_(j:N,:)');%./lambda_;
%         X_j     = kron(A_(j:N,j),X);%./lambda_;
% 
%         % run HS prior
%         [Beta,lambda(j,:),tau(j),nu(j,:),xi(j),sigsq] = nb_bVarEstimator.horseshoePrior(Y_j,X_j,X_j'*X_j,lambda(j,:)',tau(j),nu(j,:),xi(j),sig_sq(j),type);%sqrt_ht(j,1),2);
% 
% 
%         % posterior draw
%         PAI(:,j)      = Beta;
%         sigma_sq(j,1) = sigsq;
%     end
%     
%     % construct companion form
%     PAIc = [PAI(2:end,:)'; eye(N*(R-1)), zeros(N*(R-1),N)];
%     
%     % Ensure stationary draws
%     counter  = 0;
%     counter2 = 0;
%     while max(abs(eig(PAIc)))>0.999
%         
%         if counter > 25
%            warning('\n Trouble finding stationary draws!')
%            counter2 = counter2+1;
%         end
%         if counter2 <2
%             for j=1:N
% 
%                 % select coefficients of equation j to remove from the LHS
%                 PAI(:,j) = zeros(K,1); 
% 
%                 % build model
%                 %lambda_ = vec(sqrt_ht(:,j:N));
%                 Y_j     = vec((Y-X*PAI)*A_(j:N,:)');%./lambda_;
%                 X_j     = kron(A_(j:N,j),X);%./lambda_;
% 
%                 % run HS prior
%                 [Beta,lambda(j,:),tau(j),nu(j,:),xi(j),sigsq] = nb_bVarEstimator.horseshoePrior(Y_j,X_j,X_j'*X_j,lambda(j,:)',tau(j),nu(j,:),xi(j),sig_sq(j),type);%sqrt_ht(j,1),2);
% 
% 
%                 % posterior draw
%                 PAI(:,j)      = Beta;
%                 sigma_sq(j,1) = sigsq;
%             end
%         else
%             warning('Too many explosive draws! Draws will be adjusted to get the sampler going. If this issue persists, consider terminating estimation.')
%             PAI = 0.90.*PAI_old;
%             %sigma_sq = sigsq_old;
%         end
%         PAIc = [PAI(2:end,:)'; eye(N*(R-1)), zeros(N*(R-1),N)];
%         counter = counter + 1;
%     end
% 
    
    %% Alternative approximate approach to reduce computational cost and enhance stability
     resid  = zeros(size(Y,1),N);
     A_ = eye(N);
     for j=1:N
        X_j = [X resid(:,1:j-1)];
        
        [Beta] = randn_Gibbs(Y(:,j)./sqrt(sig_sq(:,j)),X_j./sqrt(sig_sq(:,j)),1,[lambda(j,:)'.*tau(j);9*ones(j-1,1)]);
        PAI(:,j) = Beta(1:K);
        A_(j,1:j-1) = Beta(K+1:end);
        [lambda(j,:),tau(j),nu(j,:),xi(j)] = horseshoe_MS(PAI(:,j),K,tau(j),nu(j,:),xi(j));
        
        resid(:,j) = Y(:,j)-X_j*Beta;
     end
     
     % construct companion form
    PAIc = [PAI(2:end,:)'; eye(N*(R-1)), zeros(N*(R-1),N)];
    
    % Ensure stationary draws
    counter  = 0;
    counter2 = 0;
    while max(abs(eig(PAIc)))>1.05
        
        if counter > 5
           warning('\n Trouble finding stationary draws!')
           counter2 = counter2+1;
        end
        if counter2 <2
            for j=1:N

%                 % select coefficients of equation j to remove from the LHS
%                 PAI(:,j) = zeros(K,1); 
% 
%                 % build model
%                 %lambda_ = vec(sqrt_ht(:,j:N));
%                 Y_j     = vec((Y-X*PAI)*A_(j:N,:)');%./lambda_;
%                 X_j     = kron(A_(j:N,j),X);%./lambda_;
% 
%                 % run HS prior
%                 [Beta,lambda(j,:),tau(j),nu(j,:),xi(j),sigsq] = nb_bVarEstimator.horseshoePrior(Y_j,X_j,X_j'*X_j,lambda(j,:)',tau(j),nu(j,:),xi(j),sig_sq(j),type);%sqrt_ht(j,1),2);
% 
% 
%                 % posterior draw
%                 PAI(:,j)      = Beta;
%                 sigma_sq(j,1) = sigsq;
                X_j = [X resid(:,1:j-1)];

                [Beta] = randn_Gibbs(Y(:,j)./sqrt(sig_sq(:,j)),X_j./sqrt(sig_sq(:,j)),1,[lambda(j,:)'.*tau(j);9*ones(j-1,1)]);
                PAI(:,j) = Beta(1:K);
                A_(j,1:j-1) = Beta(K+1:end);
                [lambda(j,:),tau(j),nu(j,:),xi(j)] = horseshoe_MS(PAI(:,j),K,tau(j),nu(j,:),xi(j));

                resid(:,j) = Y(:,j)-X_j*Beta;
            end
        else
            warning('Too many explosive draws! Draws will be adjusted to get the sampler going. If this issue persists, consider terminating estimation.')
            PAI = 0.10.*PAI_old;
            %sigma_sq = sigsq_old;
        end
        PAIc = [PAI(2:end,:)'; eye(N*(R-1)), zeros(N*(R-1),N)];
        counter = counter + 1;
    end
    
    sigma_sq = sig_sq;
    
end
                    
  
function [Beta] = randn_Gibbs(y,X,sigma_sq,lambda_star)

    [n,p] = size(X);
    I_n = eye(n);
    if p>n
        U = bsxfun(@times,lambda_star,X');
        % step 1
        u = normrnd(0,sqrt(lambda_star));
        v = X*u + randn(n,1);
        % step 2
        v_star = (X*U+I_n)\((y/sqrt(sigma_sq))-v);
        Beta   = sqrt(sigma_sq)*(u+U*v_star);
    else  
        Q_star = X'*X;
        L     = chol((1/sigma_sq)*(Q_star+diag(1./lambda_star)),'lower');
        v     = L\((y'*X)./sigma_sq)';
        mu    = L'\v;
        u     = L'\randn(p,1);
        Beta  = mu + u;  
    end
end

function [lambda_sq,tau_sq,nu,xi] = horseshoe_MS(Beta,n,tau,nu,xi)
        
        % sample lambda and nu
        rate = (Beta.^2)/(2*tau^2) + 1./nu';
        lambda_sq = min(1e+4,1./gamrnd(1,1./rate));    % random inv gamma with shape=1, rate=rate
        nu = min(1e+3,1./gamrnd(1,1./(1 + 1./lambda_sq)))';       % random inv gamma with shape=1, rate=1+1/lambda_sq_12
        
        % sample tau and xi    
        rate = 1/xi + sum((Beta.^2)./(2*lambda_sq));
        tau_sq = min(1e+4,1./gamrnd((n+1)/2, 1./rate));    % inv gamma w/ shape=(p*(p-1)/2+1)/2, rate=rate
        xi = min(1e+3,1/gamrnd(1,1/(1 + 1/tau_sq)));               % inv gamma w/ shape=1, rate=1+1/tau_sq
end
