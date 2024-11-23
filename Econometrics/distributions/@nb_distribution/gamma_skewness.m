function x = gamma_skewness(~,k)
% Syntax:
%
% x = nb_distribution.gamma_skewness(m,k)
%
% Description:
%
% Skewness of the gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - x : The skewness of the gamma distribution
%
% See also:
% nb_distribution.gamma_median, nb_distribution.gamma_mean, 
% nb_distribution.gamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = 2/sqrt(k);

end
