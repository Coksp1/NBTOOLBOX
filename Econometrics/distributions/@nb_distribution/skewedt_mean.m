function x = skewedt_mean(a,~,~,d)
% Syntax:
%
% x = nb_distribution.skewedt_mean(a,b,c,d)
%
% Description:
%
% Mean of the generalized skewed t-distribution.
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
% - x : The mean of the distribution
%
% See also:
% nb_distribution.skewedt_mode, nb_distribution.skewedt_median, 
% nb_distribution.skewedt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if d > 0.5
        x = a;
    else
        x = nan;
    end

end
