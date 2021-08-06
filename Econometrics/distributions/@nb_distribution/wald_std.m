function x = wald_std(m,k)
% Syntax:
%
% x = nb_distribution.wald_std(m,k)
%
% Description:
%
% Standard deviation of the wald distribution
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
% - x : The standard deviation of the wald distribution
%
% See also:
% nb_distribution.wald_mode, nb_distribution.wald_median, 
% nb_distribution.wald_mean, nb_distribution.wald_std 
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = sqrt(nb_distribution.wald_variance(m,k));

end
