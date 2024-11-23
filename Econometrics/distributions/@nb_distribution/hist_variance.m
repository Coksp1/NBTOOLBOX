function x = hist_variance(a)
% Syntax:
%
% x = nb_distribution.hist_variance(a)
%
% Description:
%
% Empirical variance.
% 
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The variance of the data.
%
% See also:
% nb_distribution.hist_mode, nb_distribution.hist_median, 
% nb_distribution.hist_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = variance(a,0,1);
    
end

