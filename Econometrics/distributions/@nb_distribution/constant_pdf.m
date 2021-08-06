function f = constant_pdf(x,m)
% Syntax:
%
% f = nb_distribution.constant_pdf(x,m)
%
% Description:
%
% PDF of a constant
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The constant
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.constant_cdf, nb_distribution.constant_rand, 
% nb_distribution.constant_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f       = zeros(size(x));
    f(x==m) = 1;
     
end
