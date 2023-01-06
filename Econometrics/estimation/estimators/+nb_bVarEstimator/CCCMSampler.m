function [PAI,lambda,tau] = CCCMSampler(Y,X,N,K,~,A_,sqrt_ht,PAI,lambda,tau)
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    for j=1:N

        % select coefficients of equation j to remove from the LHS
        PAI(:,j) = zeros(K,1); 

        % build model
        lambda_ = vec(sqrt_ht(:,j:N));
        Y_j     = vec((Y-X*PAI)*A_(j:N,:)')./lambda_;
        X_j     = kron(A_(j:N,j),X)./lambda_;

        % run HS prior
        [Beta,lambda(:,j),tau(j),~] = nb_bVarEstimator.horseshoePrior(Y_j,X_j,X_j'*X_j,lambda(:,j),tau(j),sqrt_ht(j,1),2);

        % posterior draw
        PAI(:,j) = Beta;

    end
    
end
                    
  
