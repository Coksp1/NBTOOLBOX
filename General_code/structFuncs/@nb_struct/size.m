function varargout = size(obj,varargin)
 % Syntax:
%
% varargout = size(obj,varargin)
%
% Description:
%
% Get the size of the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the size function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the size function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [varargout{1:nargout}] = size(obj.s,varargin{:});

end
