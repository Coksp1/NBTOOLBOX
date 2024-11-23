function x = wald_median(m,k)
% Syntax:
%
% x = nb_distribution.wald_median(m,k)
%
% Description:
%
% Median of the wald distribution
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
% - x : The median of the wald distribution
%
% See also:
% nb_distribution.wald_mode, nb_distribution.wald_mean, 
% nb_distribution.wald_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = nb_distribution.wald_icdf(0.5,m,k);

end
