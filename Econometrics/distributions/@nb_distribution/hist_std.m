function x = hist_std(a)
% Syntax:
%
% x = nb_distribution.hist_std(a)
%
% Description:
%
% Empirical standard deviation.
% 
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The standard deviation of the data.
%
% See also:
% nb_distribution.hist_mode, nb_distribution.hist_median, 
% nb_distribution.hist_mean, nb_distribution.hist_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = std(a,0,1);

end
