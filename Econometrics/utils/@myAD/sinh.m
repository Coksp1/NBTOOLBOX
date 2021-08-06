function x = sinh(x)
% Syntax:
%
% x = sin(x)
%
% Description:
%
% Hyperbolic sine.
% 
% Written by SeHyoun Ahn, Jan 2016

    x.derivatives = valXder(cosh(x.values), x.derivatives);
    x.values      = sinh(x.values);
    
end
