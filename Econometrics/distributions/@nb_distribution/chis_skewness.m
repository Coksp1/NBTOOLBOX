function x = chis_skewness(m)
% Syntax:
%
% x = nb_distribution.chis_skewness(m)
%
% Description:
%
% Skewness of the chi squared distribution
% 
% Input:
% 
% - m : A parameter such that the mean is m
%
% Output:
% 
% - x : The skewness of the chi squared distribution
%
% See also:
% nb_distribution.chis_median, nb_distribution.chis_mean, 
% nb_distribution.chis_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = sqrt(8/m);

end
