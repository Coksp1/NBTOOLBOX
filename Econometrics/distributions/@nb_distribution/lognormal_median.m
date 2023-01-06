function x = lognormal_median(m,~)
% Syntax:
%
% x = nb_distribution.lognormal_median(m,k)
%
% Description:
%
% Median of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
%
% Output:
% 
% - x : The median of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_mode, nb_distribution.lognormal_mean, 
% nb_distribution.lognormal_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = exp(m);

end
