function x = wald_skewness(m,k)
% Syntax:
%
% x = nb_distribution.wald_skewness(m,k)
%
% Description:
%
% Skewness of the wald distribution
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
% - x : The skewness of the wald distribution
%
% See also:
% nb_distribution.wald_median, nb_distribution.wald_mean, 
% nb_distribution.wald_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = 3*sqrt(m/k);

end
