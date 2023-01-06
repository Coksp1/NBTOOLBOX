function deleteRow(gui,~,~)
% Add row to the lookupmatrix (i.e. the table)

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the rows to delete
    row = gui.selectedCells;
    if isempty(row)
        return;
    end
    
    name = 'Delete Rows';
    nb_confirmWindow('Are you sure you want to delete the selected rows?',@notClose,{@delete,gui,row},name)

end

%==================================================================
% Callbacks
%==================================================================
function notClose(hObject,~)

    close(get(hObject,'parent'));

end

function delete(hObject,~,gui,row)
% Delete rows callback

    current = get(gui.table,'data');
    ind     = [1:row(1,1)-1,row(1,2)+1:size(current,1)];
    new     = current(ind,:);
    if isempty(new)
        new   = [1,1];
    end
    set(gui.table,'data',new);

    % Assign plotter object
    obj       = gui.parent;
    obj.xData = new(:,1);
    obj.yData = new(:,2);
    
    % Notify listeners
    update(obj)
    notify(obj,'annotationEdited')

    % Close window
    close(get(hObject,'parent'));

end
