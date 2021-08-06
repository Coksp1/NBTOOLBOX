function x = sin(x)
% Syntax:
%
% x = sin(x)
%
% Description:
%
% Sine.
% 
% Edited by SeHyoun Ahn, May 2016
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    x.derivatives = valXder(cos(x.values(:)), x.derivatives);
    x.values      = sin(x.values);
    
end
