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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the rows to delete
    row = gui.selectedCells;
    if isempty(row)
        return;
    end
    
    nb_confirmWindow('Are you sure you want to delete the selected rows?',@notDelete,{@delete,gui,row},'Delete Rows')

end

%==================================================================
% Callbacks
%==================================================================
function notDelete(hObject,~)

    close(get(hObject,'parent'));

end

function delete(hObject,~,gui,row)
% Delete rows callback

    current = get(gui.table2,'data');
    ind     = [1:row(1,1)-1,row(1,2)+1:size(current,1)];
    new     = current(ind,:);
    if isempty(new)
        new   = {'',''};
    end
    set(gui.table2,'data',new);

    % Udate the graph
    xTickLabels          = cell(1,size(new,1)*2);
    xTickLabels(1:2:end) = new(:,1)';
    xTickLabels(2:2:end) = new(:,2)';
    gui.plotter.set('xTickLabels',xTickLabels);
    notify(gui,'changedGraph');
    
    % Close window
    close(get(hObject,'parent'));

end
