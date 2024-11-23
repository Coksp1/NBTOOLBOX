function setTable(obj,propertyName,propertyValue)
% Syntax:
%
% setTable(obj,propertyName,propertyValue)
%
% Description:
%
% Set underlying table properties, which is of class nb_table.
% 
% Input:
% 
% - obj           : An object of class nb_table_data_source
%
% - propertyName  : Name of the property to set.
% 
% - propertyValue : Value of the property to set.
%
% See also:
% nb_table
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    set(obj.table,propertyName,propertyValue);

end
