function x = skewedt_kurtosis(~,b,c,d)
% Syntax:
%
% x = nb_distribution.skewedt_kurtosis(a,b,c,d)
%
% Description:
%
% Kurtosis of the generalized skewed t-distribution.
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
% - x : The kurtosis of the distribution
%
% See also:
% nb_distribution.skewedt_median, nb_distribution.skewedt_mean, 
% nb_distribution.skewedt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if d > 2
        v   = d^(0.5)*sqrt((3*c^2 + 1)*(1/(2*c-2)) - 4*c^2/pi*((gamma(d-0.5)/gamma(d))^2));
        b05 = beta(0.5,d);
        b1  = beta(1,d - 0.5);
        x1  = d^2*(v*b)^4;
        x2  = b05^4;
        x3  = 48*c^4*b1^4;
        x4  = 24*c^2*(1 + 3*c^2)*b05*b1^2*beta(1.5,d - 1);
        x5  = 32*c^2*(1 + c^2)*b05^2*b1*beta(2,d - 1.5);
        x6  = (1 + 10*c^2 + 5*c^4)*b05^3*beta(2.5,d - 2);
        x   = (x1/x2)*(-x3 + x4 - x5 + x6) + 3;
    else
        x = nan;
    end
    
end
