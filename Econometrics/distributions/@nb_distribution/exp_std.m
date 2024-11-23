function x = exp_std(m)
% Syntax:
%
% x = nb_distribution.exp_std(m)
%
% Description:
%
% Standard deviation of the exponential distribution.
% 
% Input:
% 
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - x : The standard deviation of the exponential distribution
%
% See also:
% nb_distribution.exp_mode, nb_distribution.exp_median, 
% nb_distribution.exp_mean, nb_distribution.exp_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = sqrt(m^(-2));

end
