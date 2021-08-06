function x = chis_std(m)
% Syntax:
%
% x = nb_distribution.chis_std(m)
%
% Description:
%
% Standard deviation of the chi squares distribution
% 
% Input:
% 
% - m : A parameter such that the mean is m
%
% Output:
% 
% - x : The standard deviation of the chi squared distribution
%
% See also:
% nb_distribution.chis_mode, nb_distribution.chis_median, 
% nb_distribution.chis_mean, nb_distribution.chis_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(2*m);

end
