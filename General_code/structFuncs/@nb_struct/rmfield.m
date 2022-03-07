function obj = rmfield(obj,field)
% Syntax:
%
% obj = rmfield(obj,field)
%
% Description:
%
% Remova a field from the nb_struct object.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the rmfield function of a normal 
%   MATLAB struct.
%
% Output:
% 
% obj : An object of class nb_struct.
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.s = rmfield(obj.s,field); 

end
