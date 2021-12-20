function x = invgamma_median(m,k)
% Syntax:
%
% x = nb_distribution.invgamma_median(m,k)
%
% Description:
%
% Median of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The median of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_mode, nb_distribution.invgamma_mean, 
% nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        x = nb_distribution.invgamma_icdf(0.5,m,k);
    catch %#ok<CTCH>
        x = nan;
    end

end
