function x = uniform_mode(m,k)
% Syntax:
%
% x = nb_distribution.uniform_mode(m,k)
%
% Description:
%
% Mode of the uniform distribution. ANy point between m and k. Return the
% mid point (mean).
% 
% Input:
% 
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - x : The mode of the uniform distribution
%
% See also:
% nb_distribution.uniform_median, nb_distribution.uniform_mean, 
% nb_distribution.uniform_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = 0.5*(m + k);

end
