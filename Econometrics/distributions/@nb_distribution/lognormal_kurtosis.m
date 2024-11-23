function x = lognormal_kurtosis(~,k)
% Syntax:
%
% x = nb_distribution.lognormal_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The kurtosis of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_median, nb_distribution.lognormal_mean, 
% nb_distribution.lognormal_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = exp(4*k^2) + 2*exp(3*k^2) + 3*exp(2*k^2) - 3;

end
