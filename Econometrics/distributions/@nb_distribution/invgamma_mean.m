function x = invgamma_mean(m,k)
% Syntax:
%
% x = nb_distribution.invgamma_mean(m,k)
%
% Description:
%
% Mean of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The mean of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_mode, nb_distribution.invgamma_median, 
% nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m > 1 
        x = k/(m-1);
    else
        x = nan;
    end

end
