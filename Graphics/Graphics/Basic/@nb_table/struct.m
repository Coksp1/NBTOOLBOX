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
% - obj : An object of class nb_table
% 
% Output:
% 
% - s   : A struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    s = struct('cells',                 obj.cells,...
               'BorderColor',           obj.BorderColor,...
               'ColumnSizes',           obj.ColumnSizes,...
               'data',                  obj.data,...
               'decimals',              obj.decimals,...
               'deleteOption',          obj.deleteOption,...
               'language',              obj.language,...
               'RowSizes',              obj.RowSizes,...
               'updateOnChange',        obj.updateOnChange,...
               'allowDimensionChange',  obj.allowDimensionChange,...
               'stylingPatterns',       obj.stylingPatterns);
    
end
