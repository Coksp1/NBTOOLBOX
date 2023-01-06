function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Convert object to struct
% 
% Input:
% 
% - obj : An object of class nb_table_ts
% 
% Output:
% 
% - s   : A struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    s                       = struct@nb_table_data_source(obj);
    s.class                 = 'nb_table_ts';
    s.manuallySetEndTable   = obj.manuallySetEndTable;
    s.manuallySetStartTable = obj.manuallySetStartTable;
   
end
