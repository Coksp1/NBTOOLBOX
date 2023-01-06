function f = tri_pdf(x,m,k,d)
% Syntax:
%
% f = nb_distribution.tri_pdf(x,m,k,d)
%
% Description:
%
% PDF of the triangular distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : Lower bound of the triangular distribution.
%
% - k : Upper bound of the triangular distribution.
%
% - d : Mode of the triangular distribution.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.tri_cdf, nb_distribution.tri_rand, 
% nb_distribution.tri_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f       = x;
    f(x<d)  = 2.*(x(x<d) - m)./((k-m)*(d-m));
    f(x==d) = 2/(k-m);
    f(x>d)  = 2.*(k - x(x>d))./((k-m)*(k-d));
    f(x<m)  = 0;
    f(x>k)  = 0;
    
end
