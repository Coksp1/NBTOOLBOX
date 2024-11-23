function x = chis_icdf(p,m)
% Syntax:
%
% x = nb_distribution.chis_icdf(p,m)
%
% Description:
%
% Returns the inverse of the cdf at p of the chi squared distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : A parameter such that the mean is m
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the chis(m,k) 
%       distribution
%
% See also:
% nb_distribution.chis_cdf, nb_distribution.chis_rand, 
% nb_distribution.chis_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = max(m,0.1);
    dx = 1;
    while any(any(abs(dx) > 256*eps*max(x,1)))
        
        dx = (nb_distribution.chis_cdf(x,m) - p) ./ nb_distribution.chis_pdf(x,m);
        x  = x - dx;
        x  = x + (dx - x) / 2 .* (x<0);
        
    end

    x(p==0) = zeros;
    x(p==1) = inf;
    
end
