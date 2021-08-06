function x = lognormal_skewness(~,k)
% Syntax:
%
% x = nb_distribution.lognormal_skewness(m,k)
%
% Description:
%
% Skewness of the lognormal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The skewness of the lognormal distribution
%
% See also:
% nb_distribution.lognormal_median, nb_distribution.lognormal_mean, 
% nb_distribution.lognormal_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = (exp(k^2) + 2)*sqrt(exp(k^2) - 1);

end
