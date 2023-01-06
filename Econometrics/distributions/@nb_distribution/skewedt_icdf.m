function x = skewedt_icdf(p,a,b,c,d)
% Syntax:
%
% x = nb_distribution.skewedt_icdf(p,a,b,c,d)
%
% Description:
%
% Returns the inverse of the cdf at p of the generalized skewed 
% t-distribution.
% 
% Caution : There are may be some numerical problems with calculating the
%           CDF of this distribution, so the results in the tails may
%           wrong.
%
% Input:
% 
% - p : A vector of probabilities
%
% - a : The location parameter (mean).
% 
% - b : The scale parameter.
%
% - c : The skewness parameter.
%
% - d : The kurtosis parameter.
%
% Output:
% 
% - x : A double with the quantile at each element of p of the gamma(m,k) 
%       distribution
%
% See also:
% nb_distribution.skewedt_cdf, nb_distribution.skewedt_rand, 
% nb_distribution.skewedt_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x   = 0.5;
    dx  = 1;
    tol = eps^0.33;
    while any(any(abs(dx) > tol*max(abs(x),1)))
        dx = (nb_distribution.skewedt_cdf(x,a,b,c,d) - p) ./ nb_distribution.skewedt_pdf(x,a,b,c,d);
        x  = x - dx; 
    end
    x(p==0) = -inf;
    x(p==1) = inf;
    
end
