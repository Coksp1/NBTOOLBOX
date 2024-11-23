function f = laplace_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.laplace_pdf(x,m,k)
%
% Description:
%
% PDF of the laplace distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The location paramter. Median = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.laplace_cdf, nb_distribution.laplace_rand, 
% nb_distribution.laplace_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = exp(-abs(x - m)./k)./(2*k);
    
end
