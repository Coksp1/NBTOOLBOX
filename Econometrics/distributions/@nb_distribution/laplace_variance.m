function x = laplace_variance(~,k)
% Syntax:
%
% x = nb_distribution.laplace_variance(m,k)
%
% Description:
%
% Variance of the laplace distribution
% 
% Input:
% 
% - m : The location paramter. Median = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - x : The variance of the laplace distribution
%
% See also:
% nb_distribution.laplace_mode, nb_distribution.laplace_median, 
% nb_distribution.laplace_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = 2*k^2;

end
