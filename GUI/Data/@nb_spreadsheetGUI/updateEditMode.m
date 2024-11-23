function updateEditMode(gui,hObject,~)
% Syntax:
%
% updateEditMode(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update edit mode of table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the selected editable mode (old)
    editable = get(hObject,'checked');

    % Update the editable property
    if strcmp(editable,'on')
        gui.editMode = 0;
        set(hObject,'checked','off');
    else
        gui.editMode = 1;
        set(hObject,'checked','on');
    end

    % Then we update the table
    tableH = gui.table;
    dataT  = get(gui.table);
    dim2   = size(dataT,2);
    if gui.editMode == 1
        colEdit = true(1,dim2);
    else
        colEdit = false(1,dim2);
    end
    set(tableH,'columnEdit',colEdit);

    % Context menu (which are dependent on the edit mode)
    addContextMenu(gui) 

end 
