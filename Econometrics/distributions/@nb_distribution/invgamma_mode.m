function x = invgamma_mode(m,k)
% Syntax:
%
% x = nb_distribution.invgamma_mode(m,k)
%
% Description:
%
% Mode of the invgamma distribution
% 
% Input:
% 
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - x : The mode of the invgamma distribution
%
% See also:
% nb_distribution.invgamma_median, nb_distribution.invgamma_mean, 
% nb_distribution.invgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = k/(m+1);

end
