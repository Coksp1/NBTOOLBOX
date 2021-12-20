function x = invgamma_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.invgamma_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the invgamma(m,k) distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the  
%       invgamma(m,k) distribution
%
% See also:
% nb_distribution.invgamma_cdf, nb_distribution.invgamma_rand, 
% nb_distribution.invgamma_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = max(k/(m+1),0.1);
    dx = 1;
    kk = 0;
    while any(any(abs(dx) > 256*eps*max(x,1))) && kk < 100000
        
        dx = (nb_distribution.invgamma_cdf(x,m,k) - p) ./ nb_distribution.invgamma_pdf(x,m,k);
        x  = x - dx;
        x  = x + (dx - x) / 2 .* (x<0);
        kk = kk + 1;
        
    end

    if kk == 10000
        error([mfilename ':: Could not solve for the icdf for the provided observations :: Too many function iterations.'])
    end
    
    x(p==0) = zeros;
    x(p==1) = inf;
    
end
