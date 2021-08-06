function value = getfield(obj,varargin)
% Syntax:
%
% value = getfield(obj,varargin)
%
% Description:
%
% Get a field from the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the getfield function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the getfield function of a normal MATLAB struct.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value = getfield(obj.s,varargin{:}); 

end
