function [C,lambda] = nb_covShrinkDiag(X,lambda)
% Syntax:
%
% [C,lambda]= nb_covShrinkDiag(x,lambda)
%
% Description:
%
% Let X be a data matrix with size T x N. This function estimate the 
% covariance matrix of the data X using a shrinkage agains the diagonal
% matrix of the variances of the data in X. 
% 
% C = lambda*D + (1-lambda)*S
%
% where D is the diagonal matrix and S is the normal estimate of the
% covariance matrix ((X'*X)/(T-1))
%
% References:
%
% Kwan (2011), "An Introduction to Shrinkage Estimation of the
% Covariance Matrix: A Pedagogic Illustration"
%
% Input:
% 
% - X      : A T x N double where T is the number of observations and N 
%            is the number of variables.
% 
% - lambda : Give this input, if you want to set the shrinkage parameter
%            based on judgment. Must in this case be a number between 0
%            and 1. Default is to estimate lambda as in Kwan (2011). 0 
%            means no shrinkage.
%
% Output:
% 
% - C      : The estimate covariance matrix.
%
% - lambda : The calculated shrinkage parameter.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % De-mean data
    [T,N] = size(X);
    mu    = mean(X);
    X     = bsxfun(@minus,X,mu);
    S     = (X'*X)/(T-1);

    % Diagonal matrix with 
    D = diag(diag(S));

    if nargin < 2

        % Calculate the variance of each element in S using equation 10
        % of Kwan (2011)
        W     = (X'*X)/T;
        XW1   = zeros(T,N^2);
        for ii = 1:N
            XW1(:,(ii-1)*N+1:N*ii) = X(:,ones(1,N)*ii);
        end
        XW2   = repmat(X,[1,N]);
        Wij   = XW1.*XW2;
        W_bar = W(:)';
        varS  = (T/((T-1)^3))*sum((bsxfun(@minus,Wij,W_bar)).^2,1);
        varS  = reshape(varS,[N,N]);

        % Calculate the shrinkage parameter using the equation 5 of
        % Kwan (2011)
        S2      = S.^2;
        lambda1 = 0;
        lambda2 = 0;
        for ii = 1:N-1
           lambda1 = lambda1 + sum(varS(ii,ii+1:end));  
           lambda2 = lambda2 + sum(varS(ii,ii+1:end) + S2(ii,ii+1:end));
        end
        lambda = lambda1/lambda2;

    else
        if ~nb_isScalarNumberClosed(lambda,0,1)
            error([mfilename ':: The lambda input must be a scalar number between 0 and 1.'])
        end
    end

    % Calculate the final estimate
    C = lambda*D + (1-lambda)*S;

end

