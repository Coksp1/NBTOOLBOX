function x = skewedt_skewness(~,b,c,d)
% Syntax:
%
% x = nb_distribution.skewedt_skewness(a,b,c,d)
%
% Description:
%
% Skewness of the generalized skewed t-distribution.
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
% - x : The skewness of the distribution
%
% See also:
% nb_distribution.skewedt_median, nb_distribution.skewedt_mean, 
% nb_distribution.skewedt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if d > 1.5
        v   = 1/(d^0.5*sqrt((3*c^2 + 1)*(1/(2*d-2)) - (4*c^2/pi)*((gamma(d-0.5)/gamma(d))^2)));
        b05 = beta(0.5,d);
        b1  = beta(1,d - 0.5);
        x1  = 2*d^1.5*c*(v*b)^3;
        x2  = b05^3;
        x3  = 8*c^2*b1^3;
        x4  = 3*(1 + 3*c^2)*b05;
        x5  = b1*beta(1.5,d - 1);
        x6  = 2*(1 + c^2)*b05^2*beta(2,d - 1.5);
        x   = (x1/x2)*(x3 - x4*x5 + x6);
    else
        x = nan;
    end

end
