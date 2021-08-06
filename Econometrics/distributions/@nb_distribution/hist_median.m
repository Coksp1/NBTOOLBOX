function x = hist_median(a)
% Syntax:
%
% x = nb_distribution.hist_median(a)
%
% Description:
%
% Empirical median.
% 
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The median of the data.
%
% See also:
% nb_distribution.hist_mode, nb_distribution.hist_mean, 
% nb_distribution.hist_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = median(a,1);

end
