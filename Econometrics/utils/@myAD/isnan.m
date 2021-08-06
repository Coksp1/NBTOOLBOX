function y = isnan(x)
% Syntax:
%
% x = isnan(x)
%
% Description:
%
% Test for nan in values or derivatives.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    y = isnan(x.values) | isnan(sum(x.derivatives,2));
    
end
