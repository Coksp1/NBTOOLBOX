function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to table.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    current = get(gui.table,'data');
    nCol    = size(current,2);
    newRow  = repmat({''},[1,nCol]);
    new     = [current;newRow];
    set(gui.table,'data',new);
    addCallback(gui);
    
end
