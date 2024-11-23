function x = skt_variance(a,b,c,d)
% Syntax:
%
% x = nb_distribution.skt_variance(a,b,c,d)
%
% Description:
%
% Variance of the Azzalini skewed t-distribution.
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
% - x : The variance of the distribution
%
% See also:
% nb_distribution.skt_mode, nb_distribution.skt_median, 
% nb_distribution.skt_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if d > 2
        if d == inf
            delta = c/sqrt(1 + c^2);
            x     = b^2*(1 - (2*delta^2)/pi);
        else
            g2 = gamma(0.5*(d));
            if g2 == inf
                delta = c/sqrt(1 + c^2);
                x     = b^2*(1 - (2*delta^2)/pi);
            else
                x = b^2*(d/(d-2)) - (nb_distribution.skt_mean(a,b,c,d) - a)^2;
            end
        end
    else
        x = nan;
    end

end
