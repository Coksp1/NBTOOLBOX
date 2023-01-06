function x = laplace_std(m,k)
% Syntax:
%
% x = nb_distribution.laplace_std(m,k)
%
% Description:
%
% Standard deviation of the laplace distribution
% 
% Input:
% 
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - x : The standard deviation of the laplace distribution
%
% See also:
% nb_distribution.laplace_mode, nb_distribution.laplace_median, 
% nb_distribution.laplace_mean, nb_distribution.laplace_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.laplace_variance(m,k));

end
