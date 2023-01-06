function x = beta_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.beta_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the beta(m,k) distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : First shape parameter of the beta distribution. The mean will
%       be given by m/(m + k)
% 
% - k : Second shape parameter of the beta distribution
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the beta(m,k) 
%       distribution
%
% See also:
% nb_distribution.beta_cdf, nb_distribution.beta_rand, 
% nb_distribution.beta_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = nb_distribution.beta_mean(m,k);
    dx = 1;
    while any(any(abs(dx) > 256*eps*max(x,1)))
        
        dx = (nb_distribution.beta_cdf(x,m,k) - p) ./ nb_distribution.beta_pdf(x,m,k);
        x  = x - dx;
        x  = x + (dx - x) / 2 .* (x<0);
        
    end

    x(p==0) = zeros;
    x(p==1) = inf;
    
end
