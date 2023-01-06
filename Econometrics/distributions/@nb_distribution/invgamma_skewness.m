function x = invgamma_skewness(m,~)
% Syntax:
%
% x = nb_distribution.invgamma_skewness(m,k)
%
% Description:
%
% Skewness of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The skewness of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_median, nb_distribution.invgamma_mean, 
% nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m > 3
        x = (4*sqrt(m - 2))/(m - 3);
    else
        x = nan; 
    end

end
