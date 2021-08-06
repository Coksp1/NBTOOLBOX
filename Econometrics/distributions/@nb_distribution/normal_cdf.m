function f = normal_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.normal_cdf(x,m,k)
%
% Description:
%
% CDF of the normal distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The mean of the distribution
% 
% - k : The std of the distribution
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.normal_pdf, nb_distribution.normal_rand,
% nb_distribution.normal_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    z = (x - m)./(k.*sqrt(2));
    f = 0.5.*erfc(-z);
    
end
