function f = skewedt_pdf(x,a,b,c,d)
% Syntax:
%
% f = nb_distribution.skewedt_pdf(x,a,b,c,d)
%
% Description:
%
% PDF of the generalized skewed t-distribution.
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
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
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.skewedt_cdf, nb_distribution.skewedt_rand, 
% nb_distribution.skewedt_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    g05  = gamma(d - 0.5);
    g05p = gamma(d + 0.5);
    v    = 1/(d^0.5*sqrt((3*c^2 + 1)*(1/(2*d-2)) - (4*c^2/pi)*((g05/gamma(d))^2)));
    m1   = 2*v*b*c*sqrt(d)*g05;
    m2   = sqrt(pi)*g05p;
    m    = m1/m2;
    f1   = ((abs(x - a + m).^2)./(d*(v*b)^2*(c*sign(x - a - m) + 1).^2) + 1).^(0.5 + d);
    f    = g05p./(v*b*sqrt(pi*d)*gamma(d)*f1);  
    
end
