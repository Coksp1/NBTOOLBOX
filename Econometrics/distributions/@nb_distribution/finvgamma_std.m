function x = finvgamma_std(m,k)
% Syntax:
%
% x = nb_distribution.finvgamma_std(m,k)
%
% Description:
%
% Standard deviation of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The standard deviation of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_mode, nb_distribution.finvgamma_median, 
% nb_distribution.finvgamma_mean, nb_distribution.finvgamma_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = sqrt(nb_distribution.finvgamma_variance(m,k));

end
