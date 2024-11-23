function obj = nb_rmfield(obj,field)
% Syntax:
%
% obj = nb_rmfield(obj,field)
%
% Description:
%
% Same as rmfield, but also handle the case where field is not a field of
% obj.
% 
% Input:
% 
% - s     : A nb_struct object.
% 
% - field : A char or cellstr.
%
% Output:
% 
% - obj   : A nb_struct object.
%
% See also:
% nb_struct.rmfield
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fieldN = fieldnames(obj.s);
    if ischar(field)
        field = cellstr(field);
    end
    ind   = ismember(field,fieldN);
    field = field(ind);
    obj.s = rmfield(obj.s,field);
    
end
