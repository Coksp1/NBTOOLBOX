function x = gamma_kurtosis(~,k)
% Syntax:
%
% x = nb_distribution.gamma_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - x : The kurtosis of the gamma distribution
%
% See also:
% nb_distribution.gamma_median, nb_distribution.gamma_mean, 
% nb_distribution.gamma_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = 6/k + 3;

end
