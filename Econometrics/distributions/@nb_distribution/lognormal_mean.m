function x = lognormal_mean(m,k)
% Syntax:
%
% x = nb_distribution.lognormal_mean(m,k)
%
% Description:
%
% Mean of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The mean of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_mode, nb_distribution.lognormal_median, 
% nb_distribution.lognormal_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = exp(m+(k^2)/2);

end
