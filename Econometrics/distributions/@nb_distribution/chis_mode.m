function x = chis_mode(m)
% Syntax:
%
% x = nb_distribution.chis_mode(m)
%
% Description:
%
% Mode of the chi squared distribution
% 
% Input:
% 
% - m : A parameter such that the mean is m
%
% Output:
% 
% - x : The mode of the chi squared distribution
%
% See also:
% nb_distribution.chis_median, nb_distribution.chis_mean, 
% nb_distribution.chis_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = max(m - 2,0);

end
