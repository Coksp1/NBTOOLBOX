function x = gamma_median(m,k)
% Syntax:
%
% x = nb_distribution.gamma_median(m,k)
%
% Description:
%
% Median of the gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - x : The median of the gamma distribution
%
% See also:
% nb_distribution.gamma_mode, nb_distribution.gamma_mean, 
% nb_distribution.gamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = nb_distribution.gamma_icdf(0.5,m,k);

end
