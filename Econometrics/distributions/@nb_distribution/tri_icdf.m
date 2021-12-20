function x = tri_icdf(p,m,k,d)
% Syntax:
%
% x = nb_distribution.tri_icdf(p,m,k,d)
%
% Description:
%
% Returns the inverse of the cdf at p of the triangular distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : Lower bound of the triangular distribution.
%
% - k : Upper bound of the triangular distribution.
%
% - d : Mode of the triangular distribution.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the triangular 
%       distribution
%
% See also:
% nb_distribution.tri_cdf, nb_distribution.tri_rand, 
% nb_distribution.tri_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    p(p>1)  = 1; 
    p(p<0)  = 0;
    x       = p;
    s       = (d-m)/(k-m);
    x(p<=s) = m + sqrt(p(p<=s)*(k-m)*(d-m));
    x(p>s)  = k - sqrt((1-p(p>s))*(k-m)*(k-d));
    
end
