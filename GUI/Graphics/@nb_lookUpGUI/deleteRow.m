function deleteRow(gui,~,~)
% Syntax:
%
% deleteRow(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add row to the lookupmatrix (i.e. the table)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    empty   = 0;
    if isempty(new)
        new   = {'','',''};
        empty = 1;
    end
    set(gui.table,'data',new);

    for ii = 1:size(new,1)
        
        ind = strfind(new{ii,2},'\\');
        if ~isempty(ind)
            splitted  = regexp(new{ii,2},'\s\\\\\s','split');
            new{ii,2} = char(splitted);
        end
        
        ind = strfind(new{ii,3},'\\');
        if ~isempty(ind)
            splitted  = regexp(new{ii,3},'\s\\\\\s','split');
            new{ii,3} = char(splitted);
        end
        
    end
    
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
