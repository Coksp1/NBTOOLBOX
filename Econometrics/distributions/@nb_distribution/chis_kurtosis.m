function x = chis_kurtosis(m)
% Syntax:
%
% x = nb_distribution.chis_kurtosis(m)
%
% Description:
%
% Kurtosis of the chi squared distribution
% 
% Input:
% 
% - m : A parameter such that the mean is m
%
% Output:
% 
% - x : The kurtosis of the chi squared distribution
%
% See also:
% nb_distribution.chis_median, nb_distribution.chis_mean, 
% nb_distribution.chis_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = 12/m + 3;

end
