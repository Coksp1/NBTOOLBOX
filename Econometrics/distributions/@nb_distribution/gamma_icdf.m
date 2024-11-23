function x = gamma_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.gamma_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the gamma(m,k) distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the gamma(m,k) 
%       distribution
%
% See also:
% nb_distribution.gamma_cdf, nb_distribution.gamma_rand, 
% nb_distribution.gamma_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = max(m*k,0.1);
    dx = 1;
    while any(any(abs(dx) > 256*eps*max(x,1)))
        
        dx = (nb_distribution.gamma_cdf(x,m,k) - p) ./ nb_distribution.gamma_pdf(x,m,k);
        x  = x - dx;
        x  = x + (dx - x) / 2 .* (x<0);
        
    end

    x(p==0) = zeros;
    x(p==1) = inf;
    
end
