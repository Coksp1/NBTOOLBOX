function updateTableType(gui,hObject,~)
% Syntax:
%
% updateTableType(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_cell')
        nb_errorWindow('Cannot set view mode when dealing with a cell object.')
        return
    end

    % Get the selected tableType
    tabType       = get(hObject,'label');
    gui.tableType = tabType;

    % Update the checking
    par        = get(hObject,'parent');
    oldHObject = findobj(par,'checked','on');
    set(oldHObject,'checked','off')
    set(hObject,'checked','on');

    % Then we update the table
    updateTable(gui);

end 
