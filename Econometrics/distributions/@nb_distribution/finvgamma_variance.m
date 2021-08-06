function x = finvgamma_variance(m,k)
% Syntax:
%
% x = nb_distribution.finvgamma_variance(m,k)
%
% Description:
%
% Variance of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The variance of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_mode, nb_distribution.finvgamma_median, 
% nb_distribution.finvgamma_mean
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if m > 2
        x = k^2/((m-1)^2*(m-2));
    else
        x = nan;
    end

end
