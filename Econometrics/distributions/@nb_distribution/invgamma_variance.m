function x = invgamma_variance(m,k)
% Syntax:
%
% x = nb_distribution.invgamma_variance(m,k)
%
% Description:
%
% Variance of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The variance of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_mode, nb_distribution.invgamma_median, 
% nb_distribution.invgamma_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m > 2
        x = k^2/((m-1)^2*(m-2));
    else
        x = nan;
    end

end
