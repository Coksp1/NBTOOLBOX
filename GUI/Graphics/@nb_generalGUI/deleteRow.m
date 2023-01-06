function deleteRow(gui,~,~)
% Syntax:
%
% deleteRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Delete row of the lookupmatrix (i.e. the table)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the rows to delete
    row = gui.selectedCells;
    if isempty(row)
        return;
    end
    
    parent = gui.plotter.parent;
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Delete Rows'];
    else
        name = 'Delete Rows';
    end
    
    nb_confirmWindow('Are you sure you want to delete the selected rows?',@not,{@delete,gui,row},name)

end

%==================================================================
% Callbacks
%==================================================================
function not(hObject,~)

    close(get(hObject,'parent'));

end

function delete(hObject,~,gui,row)
% Delete rows callback

    current = get(gui.table,'data');
    ind     = [1:row(1,1)-1,row(1,2)+1:size(current,1)];
    new     = current(ind,:);
    empty   = 0;
    if isempty(new)
        new   = {'','',''};
        empty = 1;
    end
    set(gui.table,'data',new);

    % Assign plotter object
    if empty
        gui.plotter.lookUpMatrix = {};
    else
        gui.plotter.lookUpMatrix = new;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

    % Close window
    close(get(hObject,'parent'));

end
