function U = nb_mvtncondrand(M,P,mu,sigma,l,u,indC,a,tol)
% Syntax:
%
% U = nb_mvtncondrand(M,P,mu,sigma,l,u,indC,a,tol)
%
% Description:
%
% Draw random variables from the conditional multivariate truncated normal 
% distribution. 
%
% Input:
% 
% - M     : The number of simulate observation of each variables.
%
% - P     : The number of simulate observation of each variables. (Added
%           as a page)
%
% - mu    : The mean of the variables. As a N x 1 double.
%
% - sigma : The covariance matrix. As a N x N double. Must be symmetric. 
%
% - l     : Lower bound of the truncated distribution. As a 1 x N double.
%           May include -inf.
%
% - u     : Upper bound of the truncated distribution. As a 1 x N double.
%           May include inf.
%
% - indC  : Index for the variables to condition on. As a 1 x N or N x 1 
%           logical. sum(indC) must equal Q.
%
% - a     : The values to condition on. As Q x 1 double.
%
% - tol   : The tolerance when checking for symmetri of sigma.
% 
% Output:
% 
% - U    : A M x N x P matrix.
%
% See also:
% nb_chol, nb_mvtnrand, nb_mvnrand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 9
        tol = [];
    end

    indC = indC(:);
    mu   = mu(:);
    a    = a(:);
    n    = size(mu,1);
    if n == 1
        mu = mu(ones(size(sigma,1),1),1);
        n  = size(mu,1);
    end
    if n ~= size(indC,1)
        error([mfilename ':: The index for the variables to condition on ',...
                         'does not have as many elements as mu!'])
    end
    if size(a,1) ~= sum(indC)
        error([mfilename ':: There is a conflict between the a and indC inputs.'])
    end
    
    % Now we need to partition the correlation matrix
    sigma11   = sigma(~indC,~indC);
    sigma12   = sigma(~indC,indC);
    sigma21   = sigma(indC,~indC);
    sigma22   = sigma(indC,indC);
    
    % Adjust mean given conditional information
    muCond    = mu(~indC) + sigma12/sigma22*a; 
    
    % Adjust correlation matrix
    sigmaCond = sigma11 - (sigma12/sigma22)*sigma21;
    
    % Generate random variables from the conditional multivariate 
    % distribution 
    UC = nb_mvtnrand(M,P,muCond',sigmaCond,l(~indC),u(~indC),tol);

    % Fill in for the variables that are condition on.
    U            = nan(M,size(mu,1),P);
    U(:,~indC,:) = UC;
    U(:,indC,:)  = repmat(mu(indC),[M,1,P]);
    
end
