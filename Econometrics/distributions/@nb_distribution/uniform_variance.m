function x = uniform_variance(m,k)
% Syntax:
%
% x = nb_distribution.uniform_variance(m,k)
%
% Description:
%
% Variance of the uniform distribution
% 
% Input:
% 
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - x : The variance of the uniform distribution
%
% See also:
% nb_distribution.uniform_mode, nb_distribution.uniform_median, 
% nb_distribution.uniform_mean
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = (k-m)^2/12;

end
