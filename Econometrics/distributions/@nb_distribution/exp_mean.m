function x = exp_mean(m)
% Syntax:
%
% x = nb_distribution.exp_mean(m)
%
% Description:
%
% Mean of the exponential distribution. 
% 
% Input:
% 
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - x : The mean of the exponential distribution
%
% See also:
% nb_distribution.exp_mode, nb_distribution.exp_median, 
% nb_distribution.exp_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = m^(-1);

end
