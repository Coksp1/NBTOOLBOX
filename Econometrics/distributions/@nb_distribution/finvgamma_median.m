function x = finvgamma_median(m,k)
% Syntax:
%
% x = nb_distribution.finvgamma_median(m,k)
%
% Description:
%
% Median of the flipped invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The median of the flipped invgamma distribution
%
% See also:
% nb_distribution.finvgamma_mode, nb_distribution.finvgamma_mean, 
% nb_distribution.finvgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        x = nb_distribution.finvgamma_icdf(0.5,m,k);
    catch %#ok<CTCH>
        x = nan;
    end
    
end
