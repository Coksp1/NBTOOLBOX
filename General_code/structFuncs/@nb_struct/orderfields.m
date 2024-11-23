function varargout = orderfields(obj,varargin)
% Syntax:
%
% varargout = orderfields(obj,varargin)
%
% Description:
%
% Order the fields of the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the orderfields function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the orderfields function of a normal MATLAB struct.
%   Just that the struct is switched to a nb_struct. Remember that
%   nb_struct object is of a handle class.
%
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [obj.s,varargout{2}] = orderfields(obj.s,varargin{:}); 
    varargout{1}         = obj;
    
end
