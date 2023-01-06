function x = uniform_std(m,k)
% Syntax:
%
% x = nb_distribution.uniform_std(m,k)
%
% Description:
%
% Standard deviation of the uniform distribution
% 
% Input:
% 
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - x : The standard deviation of the uniform distribution
%
% See also:
% nb_distribution.uniform_mode, nb_distribution.uniform_median, 
% nb_distribution.uniform_mean, nb_distribution.uniform_variance 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = (k - m)/sqrt(12);

end
