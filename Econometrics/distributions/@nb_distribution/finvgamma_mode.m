function x = finvgamma_mode(m,k)
% Syntax:
%
% x = nb_distribution.finvgamma_mode(m,k)
%
% Description:
%
% Mode of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The mode of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_median, nb_distribution.finvgamma_mean, 
% nb_distribution.finvgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = -k/(m+1);

end
