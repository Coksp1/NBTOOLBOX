function x = lognormal_std(m,k)
% Syntax:
%
% x = nb_distribution.lognormal_std(m,k)
%
% Description:
%
% Standard deviation of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The standard deviation of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_mode, nb_distribution.lognormal_median, 
% nb_distribution.lognormal_mean, nb_distribution.lognormal_std 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = sqrt((exp(k^2) - 1)*exp(2*m + k^2));

end
