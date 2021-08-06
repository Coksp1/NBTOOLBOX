function U = nb_mvnrandChol(M,P,mu,T)
% Syntax:
%
% U = nb_mvnrandChol(M,P,mu,T)
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
% - T     : The cholesky factorized correlation matrix. As a N x N double. 
% 
% Output:
% 
% - U    : A M x N x P matrix.
%
% See also:
% nb_mvnrand, nb_chol
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    RN = randn(M,size(T,1),P);
    U  = nan(M,size(T,2),P);
    for ii = 1:P
        U(:,:,ii) = RN(:,:,ii)*T;
    end
    U = bsxfun(@plus,U,mu);
    
end
