function U = nb_mvnrand(M,P,mu,sigma,tol)
% Syntax:
%
% U = nb_mvnrand(M,P,mu,sigma,tol)
%
% Description:
%
% Draw radom variables from the multivariate normal distribution. 
% 
% Input:
% 
% - M     : The number of simulate observation of each variables.
%
% - P     : The number of simulate observation of each variables. (Added
%           as a page)
%
% - mu    : The mean of the variables. As a 1 x N double.
%
% - sigma : The covariance matrix. As a N x N double. Must be symmetric. 
%
%           Caution: Notice that this function compared to mvnrnd made
%           by MATLAB tries to repair the covariance matrix if it is not
%           positive semi-definite. This it does by setting all eigenvalues
%           of the sigma matrix that are negative to zero.
%
% - tol   : The tolerance when checking for symmetri of sigma.
% 
% Output:
% 
% - U    : A M x N x P matrix.
%
% See also:
% nb_chol, nb_mvtnrand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5  
        tol = [];
    end
    if isempty(tol)
        tol = eps(max(diag(sigma)))^(3/4);
    end
    sigmaT = sigma';
    if any( abs(sigma(:)-sigmaT(:)) > tol)
        error([mfilename ':: The covariance matrix must be symmetric!'])
    end
    T  = nb_chol(sigma,'covrepair');
    RN = randn(M,size(T,1),P);
    U  = nan(M,size(T,2),P);
    for ii = 1:P
        U(:,:,ii) = RN(:,:,ii)*T;
    end
    mu = nb_rowVector(mu);
    U  = bsxfun(@plus,U,mu);
    
end
