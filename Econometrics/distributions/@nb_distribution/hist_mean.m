function x = hist_mean(a)
% Syntax:
%
% x = nb_distribution.hist_mean(a)
%
% Description:
%
% Empirical mean.
% 
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The mean of the data.
%
% See also:
% nb_distribution.hist_mode, nb_distribution.hist_median, 
% nb_distribution.hist_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = mean(a,1);
    
end
