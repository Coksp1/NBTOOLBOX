function f = uniform_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.uniform_pdf(x,m,k)
%
% Description:
%
% PDF of the uniform distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.uniform_cdf, nb_distribution.uniform_rand, 
% nb_distribution.uniform_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f              = nan(size(x));
    f(x>=m & x<=k) = 1/(k - m);
    f(x<m)         = 0;
    f(x>k)         = 0;
    
end
