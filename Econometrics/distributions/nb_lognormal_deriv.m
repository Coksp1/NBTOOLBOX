function x = nb_lognormal_deriv(x,m,k)
% Syntax:
%
% x = nb_lognormal_deriv(x,m,k)
%
% Description:
%
% Derivate of the log normal distribution.
% 
% Input:
% 
% - x : The point to evaluate the derivative of the log normal PDF, as a 
%       double.
%
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
% 
% Output:
% 
% - x : The derivatives of the log normal PDF at the evaluated points, 
%       same size as x.
%
% See also:
% nb_distribution, nb_distribution.lognormal_pdf, 
% nb_distribution.lognormal_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    t = exp(-0.5*((x - m)./k).^2)/sqrt(2*pi*k^2);
    x = -(1/x)*((log(x) - m)/k)*t;
    
end
