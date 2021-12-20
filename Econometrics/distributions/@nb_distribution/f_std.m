function x = f_std(m,k)
% Syntax:
%
% x = nb_distribution.f_std(m,k)
%
% Description:
%
% Standard deviation of the F(m,k) distribution. Only defined for k > 4.
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
% - x : The standard deviation of the F(m,k) distribution
%
% See also:
% nb_distribution.f_mode, nb_distribution.f_median, 
% nb_distribution.f_mean, nb_distribution.f_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.f_variance(m,k));

end
