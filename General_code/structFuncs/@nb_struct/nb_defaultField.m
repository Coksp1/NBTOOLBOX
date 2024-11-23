function obj = nb_defaultField(obj,field,default)
% Syntax:
%
% obj = nb_defaultField(obj,field,default)
%
% Description:
%
% Add field with default value if not found found to be a field of an
% existing nb_struct obj.
% 
% Input:
% 
% - obj     : An object of class nb_struct.
%
% - field   : Name of field. As a 1xN char.
%
% - default : Default value assign to field if not found.
% 
% Output:
% 
% - obj     : An object of class nb_struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(obj.s,field)
        obj.s.(field) = default;
    end
    
end
