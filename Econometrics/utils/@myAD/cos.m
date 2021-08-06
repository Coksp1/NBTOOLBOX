function x = cos(x)
% Syntax:
%
% x = acos(x)
%
% Description:
%
% Cosine.
% 
% Edited by SeHyoun Ahn, May 2016
%
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    x.derivatives = valXder(-sin(x.values(:)), x.derivatives);
    x.values = cos(x.values);
    
end
