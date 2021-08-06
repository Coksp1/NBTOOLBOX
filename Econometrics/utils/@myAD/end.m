function ind = end(x,varargin)
% Syntax:
%
% x = end(x,varargin)
%
% Description:
%
% end operator.
% 
% Edited by SeHyoun Ahn, Jan 2016
%
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    ind = size(x.values,varargin{1});
    
end
