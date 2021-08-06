function f = tri_cdf(x,m,k,d)
% Syntax:
%
% f = nb_distribution.tri_cdf(x,m,k,d)
%
% Description:
%
% CDF of the triangular distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : Lower bound of the triangular distribution.
%
% - k : Upper bound of the triangular distribution.
%
% - d : Mode of the triangular distribution.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.tri_pdf, nb_distribution.tri_rand,
% nb_distribution.tri_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x(x>k)  = k; 
    x(x<m)  = m;
    f       = x;
    f(x<d)  = (x(x<d) - m).^2./((k-m)*(d-m));
    f(x>d)  = 1 - (k - x(x>d)).^2./((k-m)*(k-d));
    if d == m
        f(x==d) = 0;
    elseif d == k
        f(x==k) = 1;
    else
        f(x==d) = (x(x==d) - m).^2./((k-m)*(d-m));
    end
    
end
