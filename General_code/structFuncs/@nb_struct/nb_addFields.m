function c = nb_addFields(obj,fields)
% Syntax:
%
% s = nb_addFields(obj, fields)
%
% Description:
%
% Add empty fields to a nb_struct.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the nb_addFields function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the nb_addFields function of a normal MATLAB struct.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    c = nb_addFields(obj.s,fields); 

end
