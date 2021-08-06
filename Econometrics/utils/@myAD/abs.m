function x = abs(x)
% Syntax:
%
% x = abs(x)
%
% Description:
%
% Absolute value.
% 
% Edited by SeHyoun Ahn, Jan 2016
%
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    x.derivatives = valXder(sign(x.values(:)),x.derivatives);
    x.values      = abs(x.values);
    
end
