function x = chis_median(m)
% Syntax:
%
% x = nb_distribution.chis_median(m)
%
% Description:
%
% Median of the chi squared distribution
% 
% Input:
% 
% - m : A parameter such that the mean is m
%
% Output:
% 
% - x : The median of the chi squared distribution
%
% See also:
% nb_distribution.chis_mode, nb_distribution.chis_mean, 
% nb_distribution.chis_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = nb_distribution.chis_icdf(0.5,m);

end
