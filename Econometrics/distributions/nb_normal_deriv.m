function x = nb_normal_deriv(x,m,k)
% Syntax:
%
% x = nb_normal_deriv(x,m,k)
%
% Description:
%
% Derivate of the normal distribution.
% 
% Input:
% 
% - x : The point to evaluate the derivative of the normal PDF, as a 
%       double.
%
% - m : The mean of the distribution.
% 
% - k : The std of the distribution.
% 
% Output:
% 
% - x : The derivatives of the normal PDF at the evaluated points, 
%       same size as x.
%
% See also:
% nb_distribution, nb_distribution.normal_pdf, 
% nb_distribution.normal_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = -((x-m)/(sqrt(2*pi)*k^3))*exp(-0.5*((x - m)./k).^2);
    
end
