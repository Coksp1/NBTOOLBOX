function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to the lookupmatrix (i.e. the table)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    current = get(gui.table,'data');
    new     = [current;{'','',''}];
    set(gui.table,'data',new);

    gui.plotter.lookUpMatrix = new;
    
end
