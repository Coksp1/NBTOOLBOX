function x = gamma_std(m,k)
% Syntax:
%
% x = nb_distribution.gamma_std(m,k)
%
% Description:
%
% Standard deviation of the gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - x : The standard deviation of the gamma distribution
%
% See also:
% nb_distribution.gamma_mode, nb_distribution.gamma_median, 
% nb_distribution.gamma_mean, nb_distribution.gamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(m*(k^2));

end
