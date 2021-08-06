function x = invgamma_std(m,k)
% Syntax:
%
% x = nb_distribution.invgamma_std(m,k)
%
% Description:
%
% Standard deviation of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The standard deviation of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_mode, nb_distribution.invgamma_median, 
% nb_distribution.invgamma_mean, nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.invgamma_variance(m,k));

end
