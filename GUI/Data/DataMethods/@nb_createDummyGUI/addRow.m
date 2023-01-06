function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    current = get(gui.table,'data');
    new     = [current;{gui.data.variables{1},'<','0','&'}];
    set(gui.table,'data',new);

end
