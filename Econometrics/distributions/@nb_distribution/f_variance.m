function x = f_variance(m,k)
% Syntax:
%
% x = nb_distribution.f_variance(m,k)
%
% Description:
%
% Variance of the F(m,k) distribution. Only defined for k > 4.
% Will return nan otherwise.
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
% - x : The variance of the F(m,k) distribution
%
% See also:
% nb_distribution.f_mode, nb_distribution.f_median, 
% nb_distribution.f_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if k > 4
        x = 2*k^2*(m + k - 2);
        y = m*(k - 2)^2*(k - 4);
        x = x/y;
    else
        x = nan;
    end

end
