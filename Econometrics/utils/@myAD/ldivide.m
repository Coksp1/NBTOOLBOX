function x = ldivide(x,y)
% Syntax:
%
% x = ldivide(x,y)
%
% Description:
%
% Same as rdivide.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    x = rdivide(y,x);
    
end
