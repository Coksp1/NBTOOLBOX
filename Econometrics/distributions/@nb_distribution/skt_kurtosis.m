function x = skt_kurtosis(~,b,c,d)
% Syntax:
%
% x = nb_distribution.skt_kurtosis(a,b,c,d)
%
% Description:
%
% Kurtosis of the Azzalini skewed t-distribution.
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
% - x : The kurtosis of the distribution
%
% See also:
% nb_distribution.skt_median, nb_distribution.skt_mean, 
% nb_distribution.skt_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if d > 4
        if d == inf
            delta = c/sqrt(1 + c^2);
            x     = (2*(pi - 3))*(((delta*sqrt(2/pi))^4)/((1 - (2*delta^2)/pi)^2) );
        else
            delta = b*c/sqrt(1 + b*c^2);
            g1    = gamma(0.5*(d - 1));
            if g1 == inf
                delta = c/sqrt(1 + c^2);
                x     = (2*(pi - 3))*(((delta*sqrt(2/pi))^4)/((1 - (2*delta^2)/pi)^2) );
            else
                mu = delta*sqrt(d/pi)*(gamma(0.5*(d - 1))/gamma(0.5*d));
                k1 = (3*d^2)/((d - 2)*(d - 4));
                k2 = (4*mu^2*d*(3 - delta^2))/(d - 3);
                k3 = (6*mu^2*d)/(d - 2);
                k4 = (d/(d - 2) - mu^2)^(-2);
                x  = (k1 - k2 + k3 - 3*mu^4)*k4 - 3;
            end
        end
        x = x + 3;
    else
        x = nan;
    end
    
end
