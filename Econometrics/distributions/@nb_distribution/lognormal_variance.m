function x = lognormal_variance(m,k)
% Syntax:
%
% x = nb_distribution.lognormal_variance(m,k)
%
% Description:
%
% Variance of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The variance of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_mode, nb_distribution.lognormal_median, 
% nb_distribution.lognormal_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = (exp(k^2) - 1)*exp(2*m + k^2);

end
