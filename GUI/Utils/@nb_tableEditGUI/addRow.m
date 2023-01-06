function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    current = get(gui.table,'data');
    nCol    = size(current,2);
    newRow  = repmat({''},[1,nCol]);
    new     = [current;newRow];
    set(gui.table,'data',new);
    addCallback(gui);
    
end
