function f = exp_cdf(x,m)
% Syntax:
%
% f = nb_distribution.exp_cdf(x,m)
%
% Description:
%
% CDF of the exponential distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.exp_pdf, nb_distribution.exp_rand,
% nb_distribution.exp_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f      = 1 - exp(-m*x);
    f(x<0) = zeros;
    
end
