function x = logistic_std(m,k)
% Syntax:
%
% x = nb_distribution.logistic_std(m,k)
%
% Description:
%
% Standard deviation of the logistic distribution
% 
% Input:
% 
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - x : The standard deviation of the logistic distribution
%
% See also:
% nb_distribution.logistic_mode, nb_distribution.logistic_median, 
% nb_distribution.logistic_mean, nb_distribution.logistic_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.logistic_variance(m,k));

end
