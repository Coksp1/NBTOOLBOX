function x = lognormal_mode(m,k)
% Syntax:
%
% x = nb_distribution.lognormal_mode(m,k)
%
% Description:
%
% Mode of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
%
% Output:
% 
% - x : The mode of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_median, nb_distribution.lognormal_mean, 
% nb_distribution.lognormal_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = exp(m-k^2);

end
