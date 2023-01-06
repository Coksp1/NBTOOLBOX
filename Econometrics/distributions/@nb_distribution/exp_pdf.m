function f = exp_pdf(x,m)
% Syntax:
%
% f = nb_distribution.exp_pdf(x,m)
%
% Description:
%
% PDF of the exponential distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.exp_cdf, nb_distribution.exp_rand, 
% nb_distribution.exp_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f      = m*exp(-m*x);
    f(x<0) = zeros;
     
end
