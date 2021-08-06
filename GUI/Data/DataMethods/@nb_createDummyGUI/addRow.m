function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to the table.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    current = get(gui.table,'data');
    new     = [current;{gui.data.variables{1},'<','0','&'}];
    set(gui.table,'data',new);

end
