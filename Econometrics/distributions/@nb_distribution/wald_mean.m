function x = wald_mean(m,~)
% Syntax:
%
% x = nb_distribution.wald_mean(m,k)
%
% Description:
%
% Mean of the wald distribution
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
% - x : The mean of the wald distribution
%
% See also:
% nb_distribution.wald_mode, nb_distribution.wald_median, 
% nb_distribution.wald_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = m;

end
