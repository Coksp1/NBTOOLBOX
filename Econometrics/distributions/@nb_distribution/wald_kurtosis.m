function x = wald_kurtosis(m,k)
% Syntax:
%
% x = nb_distribution.wald_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the wald distribution
% 
% Input:
% 
% - m : The first parameter of the wald distribution. Must be a 1x1 double
%       greater than 0. E[X] = m.
% 
% - k : The second parameter of the wald distribution. Must be a 1x1 double
%       greater than 0.
%
% Output:
% 
% - x : The kurtosis of the wald distribution
%
% See also:
% nb_distribution.wald_median, nb_distribution.wald_mean, 
% nb_distribution.wald_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = 15*m/k + 3;

end
