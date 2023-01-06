function x = skewedt_variance(~,b,~,~)
% Syntax:
%
% x = nb_distribution.skewedt_variance(a,b,c,d)
%
% Description:
%
% Variance of the generalized skewed t-distribution.
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
% - x : The variance of the distribution
%
% See also:
% nb_distribution.skewedt_mode, nb_distribution.skewedt_median, 
% nb_distribution.skewedt_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = b^2;

end
