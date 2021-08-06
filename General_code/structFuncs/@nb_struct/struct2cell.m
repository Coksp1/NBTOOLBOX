function c = struct2cell(obj)
% Syntax:
%
% value = struct2cell(obj,varargin)
%
% Description:
%
% Convert a nb_struct object into a cell.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% Output:
% 
% - Same output(s) as the struct2cell function of a normal MATLAB struct.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    c = struct2cell(obj.s); 

end
