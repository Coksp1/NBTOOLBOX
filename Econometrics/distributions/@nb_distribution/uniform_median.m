function x = uniform_median(m,k)
% Syntax:
%
% x = nb_distribution.uniform_median(m,k)
%
% Description:
%
% Median of the uniform distribution
% 
% Input:
% 
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - x : The median of the uniform distribution
%
% See also:
% nb_distribution.uniform_mode, nb_distribution.uniform_mean, 
% nb_distribution.uniform_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = 0.5*(m + k);

end
