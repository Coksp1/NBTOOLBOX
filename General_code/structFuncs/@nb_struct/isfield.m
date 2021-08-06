function value = isfield(obj,varargin)
% Syntax:
%
% value = isfield(obj,varargin)
%
% Description:
%
% Is the field name a field of the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the isfield function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the isfield function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    value = isfield(obj.s,varargin{:}); 

end
