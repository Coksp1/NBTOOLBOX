function t = nb_rmfield(s,field)
% Syntax:
%
% t = nb_rmfield(s,field)
%
% Description:
%
% Same as rmfield, but also handle the case where field is not a field of
% s.
% 
% Input:
% 
% - s     : A Struct
% 
% - field : A char or cellstr.
%
% Output:
% 
% - t     : A struct.
%
% See also:
% rmfield
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    fieldN = fieldnames(s);
    if ischar(field)
        field = cellstr(field);
    end
    ind   = ismember(field,fieldN);
    field = field(ind);
    t     = rmfield(s,field);
    
end
