function x = finvgamma_mean(m,k)
% Syntax:
%
% x = nb_distribution.finvgamma_mean(m,k)
%
% Description:
%
% Mean of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The mean of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_mode, nb_distribution.finvgamma_median, 
% nb_distribution.finvgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m > 1 
        x = -k/(m-1);
    else
        x = nan;
    end

end
