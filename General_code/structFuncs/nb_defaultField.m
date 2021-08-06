function s = nb_defaultField(s,field,default)
% Syntax:
%
% s = nb_defaultField(s,field,default)
%
% Description:
%
% Add field with default value if not found found to be a field of an
% existing struct s.
% 
% Input:
% 
% - s       : A struct.
%
% - field   : Name of field. As a 1xN char.
%
% - default : Default value assign to field if not found.
% 
% Output:
% 
% - s       : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(s) > 1
        if ~isfield(s,field)
            [s.(field)] = deal(default);
        end
    else
        if ~isfield(s,field)
            s.(field) = default;
        end
    end
    
end
