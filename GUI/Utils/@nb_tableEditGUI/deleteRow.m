function deleteRow(gui,~,~)
% Syntax:
%
% deleteRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Delete row from table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the rows to delete
    gui.index = gui.selectedCells;
    if isempty(gui.index)
        return;
    end
    
    if isprop(gui,'parent')
        parent = gui.parent;
    else
        parent = [];
    end
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Delete Rows'];
    else
        name = 'Delete Rows';
    end
    
    nb_confirmWindow('Are you sure you want to delete the selected method?',@not,@gui.deleteCallback,name)

end

%==================================================================
% Callbacks
%==================================================================
function not(hObject,~)

    close(get(hObject,'parent'));

end

