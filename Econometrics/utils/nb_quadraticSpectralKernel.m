function y = nb_quadraticSpectralKernel(x)
% Syntax:
%
% y = nb_quadraticSpectralKernel(x)
%
% Description:
%
% Quadratic spectral kernel
% 
% Input:
% 
% - x : A double
% 
% Output:
% 
% - y : A double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d1 = 6*pi*x/5;
    d2 = sin(d1);
    d3 = cos(d1);
    d4 = 12*(pi)^2*(x).^2;
    y  = (25*(d2./d1 - d3))./d4;

end
