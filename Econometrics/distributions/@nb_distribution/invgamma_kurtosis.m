function x = invgamma_kurtosis(m,~)
% Syntax:
%
% x = nb_distribution.invgamma_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The kurtosis of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_median, nb_distribution.invgamma_mean, 
% nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m > 4
        x = (30*m - 66)/((m - 3)*(m - 4)) + 3;
    else
        x = nan;
    end

end
