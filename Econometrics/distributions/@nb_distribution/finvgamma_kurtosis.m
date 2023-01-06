function x = finvgamma_kurtosis(m,~)
% Syntax:
%
% x = nb_distribution.finvgamma_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The kurtosis of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_median, nb_distribution.finvgamma_mean, 
% nb_distribution.finvgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m > 4
        x = (30*m - 66)/((m - 3)*(m - 4)) + 3;
    else
        x = nan;
    end

end
