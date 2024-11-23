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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    c = nb_addFields(obj.s,fields); 

end
