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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    fields = cellstr(fields);
    for ii = 1:length(fields)
        s(1).(fields{ii}) = [];
    end
    
end
