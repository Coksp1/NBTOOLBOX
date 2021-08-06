function x = exp_median(m)
% Syntax:
%
% x = nb_distribution.exp_median(m)
%
% Description:
%
% Median of the exponential distribution
% 
% Input:
% 
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - x : The median of the exponential distribution
%
% See also:
% nb_distribution.exp_mode, nb_distribution.exp_mean, 
% nb_distribution.exp_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = m^(-1)*log(2);

end
