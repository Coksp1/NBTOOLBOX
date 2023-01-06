function x = uniform_mean(m,k)
% Syntax:
%
% x = nb_distribution.uniform_mean(m,k)
%
% Description:
%
% Mean of the uniform distribution
% 
% Input:
% 
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - x : The mean of the uniform distribution
%
% See also:
% nb_distribution.uniform_mode, nb_distribution.uniform_median, 
% nb_distribution.uniform_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = 0.5*(m + k);

end
