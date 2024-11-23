function x = hist_mode(a)
% Syntax:
%
% x = nb_distribution.hist_mode(a)
%
% Description:
%
% Empirical mode. Calculated using a kernel method.
% 
% Input:
% 
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - x : The mode of the data.
%
% See also:
% nb_distribution.hist_median, nb_distribution.hist_mean, 
% nb_distribution.hist_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = nb_mode(a,1);

end
