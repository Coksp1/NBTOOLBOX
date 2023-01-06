function x = skt_std(a,b,c,d)
% Syntax:
%
% x = nb_distribution.skt_std(a,b,c,d)
%
% Description:
%
% Standard deviation of the Azzalini skewed t-distribution.
% 
% Azzalini, A. and Capitanio,A. (2003). Distributions generated by 
% perturbation of symmetry with emphasis on a multivariate skew-t 
% distribution. J.Roy.Statist.Soc. B 65, 367-389.
% 
% Input:
% 
% - a : The location parameter.
% 
% - b : The scale parameter.
%
% - c : The shape parameter.
%
% - d : Degrees of freedom (default is positive infinity which corresponds 
%       to the skew normal distribution)
%
% Output:
% 
% - x : The standard deviation of the distribution
%
% See also:
% nb_distribution.skt_mode, nb_distribution.skt_median, 
% nb_distribution.skt_mean, nb_distribution.skt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.skt_variance(a,b,c,d));

end
