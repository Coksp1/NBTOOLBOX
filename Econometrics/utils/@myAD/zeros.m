function x = zeros(x)
% Syntax:
%
% x = zeros(x)
%
% Description:
%
% Zero out all values and derivatives.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, May 2007
% martinfink 'at' gmx.at

    x.values      = x.values*0;
    x.derivatives = x.derivatives*0;
    
end
