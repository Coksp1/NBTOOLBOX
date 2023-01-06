function deleteRow(gui,~,~)
% Syntax:
%
% deleteRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Delete row of the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the rows to delete
    row = gui.selectedCells;
    if isempty(row)
        return;
    end
    
    nb_confirmWindow('Are you sure you want to delete the selected rows?',@notDelete,{@delete,gui,row},[gui.parent.guiName ': Delete Rows'])

end

%==================================================================
% Callbacks
%==================================================================
function notDelete(hObject,~)

    close(get(hObject,'parent'));

end

function delete(hObject,~,gui,row)
% Delete rows callback

    current = get(gui.table,'data');
    ind     = [1:row(1,1)-1,row(1,2)+1:size(current,1)];
    new     = current(ind,:);
    if isempty(new)
        new = {gui.data.variables{1},'<','0','&'};
    end
    set(gui.table,'data',new);

    % Close window
    close(get(hObject,'parent'));

end
