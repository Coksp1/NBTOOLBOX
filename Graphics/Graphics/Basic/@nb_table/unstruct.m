function obj = unstruct(s)    
% Syntax:
%
% obj = nb_table.unstruct(s)
%
% Description:
%
% Convert struct to object
% 
% Input:
% 
% - s   : A struct
% 
% Output:
% 
% - obj : An object of class nb_table
%
% See also:
% nb_table.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj    = nb_table;
    fields = fieldnames(s);
    for ii = 1:length(fields)
       obj.(fields{ii}) = s.(fields{ii}); 
    end
    
end
