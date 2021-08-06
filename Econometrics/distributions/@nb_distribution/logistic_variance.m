function x = logistic_variance(~,k)
% Syntax:
%
% x = nb_distribution.logistic_variance(m,k)
%
% Description:
%
% Variance of the logistic distribution
% 
% Input:
% 
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - x : The variance of the logistic distribution
%
% See also:
% nb_distribution.logistic_mode, nb_distribution.logistic_median, 
% nb_distribution.logistic_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = (k^2*pi^2)/3;

end
