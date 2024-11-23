function s = nb_keepFields(obj, fields)
% Syntax:
%
% s = nb_keepFields(obj, fields)
%
% Description:
%
% Keep selected fields of nb_struct.
% 
% Input:
% 
% - obj    : A nb_struct object.
% 
% - fields : A cellstr.
%
% Output:
% 
% - obj    : A nb_struct object.
%
% Written by Henrik Hortemo Halvorsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.s = rmfield(obj.s, setdiff(fieldnames(obj.s), fields));
    
end
