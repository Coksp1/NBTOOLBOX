function f = fgamma_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.fgamma_cdf(x,m,k)
%
% Description:
%
% CDF of the flipped gamma distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.fgamma_pdf, nb_distribution.fgamma_rand,
% nb_distribution.fgamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x      = -x;
    f      = 1 - gammainc(x/k,m);
    f(x<0) = ones;
    
end
