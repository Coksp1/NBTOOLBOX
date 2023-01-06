function fNames = fieldnames(obj)
% Syntax:
%
% fNames = fieldnames(obj)
%
% Description:
%
% Get fieldnames of the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% Output:
% 
% - Same output(s) as the fieldnames function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    fNames = fieldnames(obj.s);

end
