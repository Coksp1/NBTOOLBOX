function x = f_kurtosis(m,k)
% Syntax:
%
% x = nb_distribution.f_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the F(m,k) distribution. Only defined for k > 8, 
% otherwise not defined (will return nan).
% 
% Input:
% 
% - m : First parameter of the distribution. Must be positive
% 
% - k : Second parameter of the distribution. A parameter such that the 
%       mean of the F-distribution is equal to k/(k-2) for k > 2. Must be
%       positive.
%
% Output:
% 
% - x : The kurtosis of the F(m,k) distribution
%
% See also:
% nb_distribution.f_median, nb_distribution.f_mean, 
% nb_distribution.f_variance, nb_distribution.f_skewness
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if k > 8
        x = m*(5*k-22)*(m + k - 2) + (k - 4)*(k -2)^2;
        y = m*(k-6)*(k-8)*(m + k - 2);
        x = (12*x)/y + 3;
    else
        x = nan;
    end

end
