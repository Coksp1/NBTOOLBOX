function editFreezeCellCallback(gui,hObject,event)
% Syntax:
%
% editFreezeCellCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
%
% Input:
% - gui     : A nb_spreadsheetGUI object
% - hObject : A uitable handle
% - event   : A cell edit event  
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    
    % Get the cell that where edited
    r = event.Indices(1);
    c = event.Indices(2);
    
    % Get the data of the table
    tData = get(hObject,'data');
    prev  = event.PreviousData;

    if isempty(event.Error)

        % Get the edited variable
        colNames = get(hObject,'columnName');
        varName  = colNames{c};
        
        % Get date or type
        rowNames = get(hObject,'rowName');
        rowName  = rowNames{r};
        
        % Get and check the edited cell;
        % Will return nan if not a "number", but I allow that as it may be 
        % wanted to remove observations
        cellValue = str2double(event.EditData); 
        
        % Assign changes to object and table (using the set.data method)
        try
            
            if isa(gui.data,'nb_cs')
                gui.data = setValue(gui.data,varName,cellValue,{rowName},gui.page);
            elseif isa(gui.data,'nb_data')
                gui.data = setValue(gui.data,varName,cellValue,str2double(rowName),str2double(rowName),gui.page);
            else
                gui.data = setValue(gui.data,varName,cellValue,rowName,rowName,gui.page);
            end
            
        catch Err
                
            % Convert back to old cell value
            tData{r,c} = prev;
            set(hObject,'data',tData);

            nb_errorWindow('Error while editing cell. Revert to old. Error: ', Err)
            return  

        end
        
        % Notify that changes has been made. This will create a backup, so
        % undo and redo works
        notify(gui,'updatedData')
        gui.changed = 1;
        
    else
        
        % Convert back to old cell value
        tData{r,c} = prev;
        set(hObject,'data',tData);
        
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end
