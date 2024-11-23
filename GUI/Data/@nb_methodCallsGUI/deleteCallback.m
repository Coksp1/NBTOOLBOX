function deleteCallback(gui,hObject,~)
% Syntax:
%
% deleteCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Delete a method call from nb_dataSource object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Close window
    close(get(hObject,'parent'));

    % Get selection
    current   = get(gui.table,'data');
    toDelete  = gui.index(1,1):gui.index(1,2);
    sourceInd = get(gui.list,'value');
    
    % Try the edited method call
    tested = deleteMethodCalls(gui.data,sourceInd,toDelete);
    try
        tested = update(tested);
    catch Err
        set(gui.table,'data',current);
        nb_errorWindow('The changes you made produced an error. Revert to old method calls.', Err)
        return
    end

    % If we get here the changes where successful
    %--------------------------------------------
    
    % Update the source list (which can be removed because of removed calls
    % to the method merge)
    [gui.sources,gui.tableData] = getMethodCalls(tested);
    set(gui.list,'string',gui.sources);
    
    % Update the table
    tableData   = gui.tableData(:,:,sourceInd);
    s2          = size(tableData,2);
    colNames    = cell(1,s2);
    colNames{1} = 'Name';
    colEdit     = true(1,s2);
    colEdit(1)  = false;
    colForm     = cell(1,s2);
    colForm(:)  = {'char'};
    set(gui.table,...
        'data',                 tableData,...
        'columnName',           colNames,...
        'columnFormat',         colForm,...
        'columnEdit',           colEdit);
    
    % Assign data property used by the listeners
    gui.data = tested;

    % Notify listeners
    notify(gui,'methodFinished')
    
    nb_infoWindow('The editing was successful!') 
    
end
