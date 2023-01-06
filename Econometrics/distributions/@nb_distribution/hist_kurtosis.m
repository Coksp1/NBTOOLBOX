function x = hist_kurtosis(a)
% Syntax:
%
% x = nb_distribution.hist_kurtosis(a,b,c,d,e)
%
% Description:
%
% Empirical kurtosis.
%
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The kurtosis of the data.
%
% See also:
% nb_distribution.hist_median, nb_distribution.hist_mean, 
% nb_distribution.hist_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Draw random numbers
    x = kurtosis(a,0,1);

    
end
