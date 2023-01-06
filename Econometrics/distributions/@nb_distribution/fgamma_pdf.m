function f = fgamma_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.fgamma_pdf(x,m,k)
%
% Description:
%
% PDF of the flipped gamma distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.fgamma_cdf, nb_distribution.fgamma_rand, 
% nb_distribution.fgamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x      = -x;
    f      = x.^(m-1).*exp(-(x/k));
    div    = k.^m.*gamma(m);
    f      = f./div;
    f(x<0) = zeros;
     
end
