function x = kernel_mode(domain,density)
% Syntax:
%
% x = nb_distribution.kernel_mode(domain,density)
%
% Description:
%
% The mode is found by finding the max point of the estimated kernel 
% density, and return the matching point in its domain.
% 
% Input:
% 
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - x : The kurtosis of the estimated kernel density
%
% See also:
% nb_distribution.kernel_median, nb_distribution.kernel_mean, 
% nb_distribution.kernel_variance, nb_distribution.kernel_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [~,ind] = max(density);
    x       = domain(ind);
    
end
