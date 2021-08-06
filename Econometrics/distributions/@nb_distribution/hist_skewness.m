function x = hist_skewness(a)
% Syntax:
%
% x = nb_distribution.hist_skewness(a)
%
% Description:
%
% Empirical skewness.
%
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The skewness of the data.
%
% See also:
% nb_distribution.hist_median, nb_distribution.hist_mean, 
% nb_distribution.hist_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = skewness(a,0,1);
    
end
