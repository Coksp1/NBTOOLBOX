function x = reshape(x,varargin)
% Syntax:
%
% x = reshape(x,varargin)
%
% Description:
%
% Reshape object.
% 
% Written by SeHyoun Ahn, Jan 2016

    x.values = reshape(x.values,varargin{:});

end
