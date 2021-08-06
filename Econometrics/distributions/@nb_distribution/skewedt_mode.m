function x = skewedt_mode(a,b,c,d)
% Syntax:
%
% x = nb_distribution.skewedt_mode(a,b,c,d)
%
% Description:
%
% Mode of the generalized skewed t-distribution.
% 
% Input:
% 
% - a : The location parameter (mean).
% 
% - b : The scale parameter.
%
% - c : The skewness parameter.
%
% - d : The kurtosis parameter.
%
% Output:
% 
% - x : The mode of the distribution
%
% See also:
% nb_distribution.skewedt_median, nb_distribution.skewedt_mean, 
% nb_distribution.skewedt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    v    = 1/(d^0.5*sqrt((3*c^2 + 1)*(1/(2*d-2)) - (4*c^2/pi)*((gamma(d-0.5)/gamma(d))^2)));
    g05  = gamma(d - 0.5);
    g05p = gamma(d + 0.5);
    m1   = 2*v*b*c*sqrt(d)*g05;
    m2   = sqrt(pi)*g05p;
    m    = m1/m2;
    if d > 0.5
        x = a + m;
    else
        x = nan;
    end

end
