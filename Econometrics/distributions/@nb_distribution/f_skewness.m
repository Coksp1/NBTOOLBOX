function x = f_skewness(m,k)
% Syntax:
%
% x = nb_distribution.f_skewness(m,k)
%
% Description:
%
% Skewness of the F(m,k) distribution. Only defined for k > 6. Will
% return nan otherwise.
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
% - x : The skewness of the F(m,k) distribution
%
% See also:
% nb_distribution.f_median, nb_distribution.f_mean, 
% nb_distribution.f_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if k > 6
        x = (2*m + k - 2)*sqrt(8*(k - 4));
        y = (k - 6)*sqrt(m*(m+ k - 2));
        x = x/y;
    else
        x = nan;
    end

end
