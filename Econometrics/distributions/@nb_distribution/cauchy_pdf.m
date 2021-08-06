function f = cauchy_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.cauchy_pdf(x,m,k)
%
% Description:
%
% PDF of the cauchy distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.cauchy_cdf, nb_distribution.cauchy_rand, 
% nb_distribution.cauchy_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f = pi.*k.*(1 + ((x - m)./k).^2);
    f = 1./f; 
    
end
