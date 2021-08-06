function addRow(gui,~,~)
% Syntax:
%
% addRow(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    current = get(gui.table2,'data');
    new     = [current;{'',''}];
    set(gui.table2,'data',new);
    
end
