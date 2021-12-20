function x = empirical_median(domain,density)
% Syntax:
%
% x = nb_distribution.empirical_median(domain,density)
%
% Description:
%
% Median of the estimated empirical CDF. This will use the 
% nb_distribution.empirical_icdf method to estimate the median.
% 
% Input:
% 
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - x : The median of the estimated kernel density
%
% See also:
% nb_distribution.kernel_mode, nb_distribution.kernel_mean, 
% nb_distribution.kernel_variance, nb_distribution.kernel_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = nb_distribution.empirical_icdf(0.5,domain,density);

end
