function f = gamma_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.gamma_cdf(x,m,k)
%
% Description:
%
% CDF of the gamma distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.gamma_pdf, nb_distribution.gamma_rand,
% nb_distribution.gamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f      = gammainc(x/k,m);
    f(x<0) = zeros;
    
end
