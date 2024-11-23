function f = normal_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.normal_pdf(x,m,k)
%
% Description:
%
% PDF of the normal distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The mean of the distribution
% 
% - k : The std of the distribution
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.normal_cdf, nb_distribution.normal_rand,
% nb_distribution.normal_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = exp(-0.5*((x - m)./k).^2)./(sqrt(2*pi).*k);
    
end
