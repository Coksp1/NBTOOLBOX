function x = finvgamma_skewness(m,~)
% Syntax:
%
% x = nb_distribution.finvgamma_skewness(m,k)
%
% Description:
%
% Skewness of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The skewness of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_median, nb_distribution.finvgamma_mean, 
% nb_distribution.finvgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if m > 3
        x = (4*sqrt(m - 2))/(m - 3);
    else
        x = nan; 
    end

end
