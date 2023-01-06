function f = finvgamma_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.finvgamma_pdf(x,m,k)
%
% Description:
%
% PDF of the flipped invgamma distribution
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
% nb_distribution.finvgamma_cdf, nb_distribution.finvgamma_rand, 
% nb_distribution.finvgamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x               = -x;
    f               = k^m.*x.^(-m-1).*exp(-(k./x));
    div             = gamma(m);
    f               = f./div;
    f(x<0)          = zeros;
    f(~isfinite(f)) = nan;
     
end
