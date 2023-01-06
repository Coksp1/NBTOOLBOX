function x = skewedt_median(a,b,c,d)
% Syntax:
%
% x = nb_distribution.skewedt_median(a,b,c,d)
%
% Description:
%
% Median of the generalized skewed t-distribution.
% 
% Input:
% 
% - a : The location parameter (mean).
% 
% - b : The scale parameter.
%
% - c : The skewness parameter.
%
% - d : The kurtosis parameter.
%
% Output:
% 
% - x : The median of the distribution
%
% See also:
% nb_distribution.skewedt_mode, nb_distribution.skewedt_mean, 
% nb_distribution.skewedt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = nb_distribution.skewedt_icdf(0.5,a,b,c,d);

end
