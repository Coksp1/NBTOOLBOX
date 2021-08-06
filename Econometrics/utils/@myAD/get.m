function varargout = get(x, varargin)
% Syntax:
%
% x = get(x,varargin)
%
% Description:
%
% Get value of property.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if nargin <2
        varargout = {};
        display(x, inputname(1));
        return;
    end

    try
        varargout{1} = x.(varargin{1});
    catch
        error(['Property ' varargin{1} ' doesn''t exist.']);
    end
    
end
