function x = wald_mode(m,k)
% Syntax:
%
% x = nb_distribution.wald_mode(m,k)
%
% Description:
%
% Mode of the wald distribution
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
% - x : The mode of the wald distribution
%
% See also:
% nb_distribution.wald_median, nb_distribution.wald_mean, 
% nb_distribution.wald_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = m*(sqrt(1 + (9*m^2)/(4*k^2)) - (3*m)/(2*k));

end
