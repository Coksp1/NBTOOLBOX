function x = skt_icdf(p,a,b,c,d)
% Syntax:
%
% x = nb_distribution.skt_icdf(p,a,b,c,d)
%
% Description:
%
% Returns the inverse of the cdf at p of the Azzalini skewed 
% t-distribution.
% 
% Azzalini, A. and Capitanio,A. (2003). Distributions generated by 
% perturbation of symmetry with emphasis on a multivariate skew-t 
% distribution. J.Roy.Statist.Soc. B 65, 367-389.
% 
% Input:
% 
% - p : A vector of probabilities
%
% - a : The location parameter (mean).
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
% - x : A double with the quantile at each element of p of the gamma(m,k) 
%       distribution
%
% See also:
% nb_distribution.skt_cdf, nb_distribution.skt_rand, 
% nb_distribution.skt_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    siz = size(p);
    p   = p(:)';
    x   = azzalini.qskt(p,a,b,c,d);
    x   = reshape(x,siz);
    
end
