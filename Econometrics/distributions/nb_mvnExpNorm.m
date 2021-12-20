function x = nb_mvnExpNorm(n,sigma)
% Syntax:
%
% x = nb_mvnExpNorm(n,sigma)
%
% Description:
%
% Calculates the expectation of the 2-norm of a multivariate normal
% distribution with diagonal covariance matrix and where all the diagonal
% elements has the same value; sigma.
%
% It is also assumed that the distribution has mean zero for all elements.
% 
% Input:
% 
% - n     : The number of variables. As a positive integer.
% 
% - sigma : The standard deviation of all the variables. As a positive 
%           double.
%
% Output:
% 
% - x     : The expected 2-norm of the distribution. As a scalar double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(sigma)
        error([mfilename ':: sigma must be a scalar number.'])
    end
    x = sigma*(sqrt(2)*gamma(0.5*(n + 1)))/gamma(0.5*n);
    
%     d = 10000;
%     y = nb_mvnrand(d,1,0,sigma*eye(n));
%     z = nan(d,1);
%     for ii = 1:d
%         z(ii) = norm(y(ii,:));
%     end
%     z = mean(z);
    
end
