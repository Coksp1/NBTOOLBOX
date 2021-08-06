function x = wald_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.wald_icdf(p,m,k)
%
% Description:
%
% Inverse CDF of the wald density
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The first parameter of the wald distribution. Must be a 1x1 double
%       greater than 0. E[X] = m.
% 
% - k : The second parameter of the wald distribution. Must be a 1x1 double
%       greater than 0.
%
% Output:
% 
% - x : The inverse CDF at the evaluated probabilities, same size as p.
%
% See also:
% nb_distribution.wald_pdf, nb_distribution.wald_rand,
% nb_distribution.wald_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = nb_distribution.wald_mode(m,k);
    dx = 1;
    while any(any(abs(dx) > 256*eps*max(x,1)))
        
        dx = (nb_distribution.wald_cdf(x,m,k) - p) ./ nb_distribution.wald_pdf(x,m,k);
        x  = x - dx;
        x  = x + (dx - x) / 2 .* (x<0);
        
    end

    x(p==0) = zeros;
    x(p==1) = inf;
    
end
