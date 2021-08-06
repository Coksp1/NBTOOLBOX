function x = f_median(m,k)
% Syntax:
%
% x = nb_distribution.f_median(m,k)
%
% Description:
%
% Median of the F(m,k) distribution
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
% - x : The median of the F(m,k) distribution
%
% See also:
% nb_distribution.f_mode, nb_distribution.f_mean, 
% nb_distribution.f_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = nb_distribution.f_icdf(0.5,m,k);

end
