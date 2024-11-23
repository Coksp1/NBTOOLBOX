function f = normal_lpdf(x,m,k)
% Syntax:
%
% f = nb_distribution.normal_lpdf(x,m,k)
%
% Description:
%
% Log of the PDF of the normal distribution (using the natural logarithm).
% 
% Input:
% 
% - x : The point to evaluate the log pdf, as a double
%
% - m : The mean of the distribution
% 
% - k : The std of the distribution
%
% Output:
% 
% - f : The log of the PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.normal_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = -0.5*((x - m)./k).^2 - log(sqrt(2*pi).*k);
    
end
