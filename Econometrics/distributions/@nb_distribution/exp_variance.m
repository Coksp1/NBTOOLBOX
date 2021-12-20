function x = exp_variance(m)
% Syntax:
%
% x = nb_distribution.exp_variance(m)
%
% Description:
%
% Variance of the exponential distribution.
% 
% Input:
% 
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - x : The variance of the exponential distribution
%
% See also:
% nb_distribution.exp_mode, nb_distribution.exp_median, 
% nb_distribution.exp_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = m^(-2);

end
