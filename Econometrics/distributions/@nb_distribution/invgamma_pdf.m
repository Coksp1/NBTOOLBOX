function f = invgamma_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.invgamma_pdf(x,m,k)
%
% Description:
%
% PDF of the invgamma distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.invgamma_cdf, nb_distribution.invgamma_rand, 
% nb_distribution.invgamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f      = k^m.*x.^(-m-1).*exp(-(k./x));
    div    = gamma(m);
    f      = f./div;
    f(x<0) = zeros;
     
end
