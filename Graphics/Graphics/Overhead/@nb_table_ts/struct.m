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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    s                       = struct@nb_table_data_source(obj);
    s.class                 = 'nb_table_ts';
    s.manuallySetEndTable   = obj.manuallySetEndTable;
    s.manuallySetStartTable = obj.manuallySetStartTable;
   
end
