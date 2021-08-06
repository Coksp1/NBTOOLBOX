function varargout = size(x, varargin)
% Syntax:
%
% x = size(x,varargin)
%
% Description:
%
% Size of object.
% 
% Written by SeHyoun Ahn, July 2016

    [varargout{1:nargout}] = size(x.values,varargin{:});
    
end
