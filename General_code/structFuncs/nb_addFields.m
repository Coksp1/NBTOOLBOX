function s = nb_addFields(s, fields)
% Syntax:
%
% s = nb_addFields(s, fields)
%
% Description:
%
% Add empty fields to a struct.
% 
% Input:
% 
% - s      : A struct.
% 
% - fields : A cellstr.
%
% Output:
% 
% - s      : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    fields = cellstr(fields);
    for ii = 1:length(fields)
        s(1).(fields{ii}) = [];
    end
    
end
