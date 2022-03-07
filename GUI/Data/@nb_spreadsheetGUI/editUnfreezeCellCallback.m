function editUnfreezeCellCallback(gui,hObject,event)
% Syntax:
%
% editUnfreezeCellCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Input:
%
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
        
        if isa(gui.data,'nb_cell')
            
            if r > objSize(gui.data,1) || c > objSize(gui.data,2)
                % Convert back to old cell value
                tData{r,c} = prev;
                set(hObject,'data',tData);
                return
            else   
                gui.data = setValue(gui.data,c,{event.EditData},r,gui.page);
            end
            
        else

            if r == 1 % Edit variable name

                % Get and check the edited cell
                new       = event.EditData;
                cellValue = str2double(new(1,1)); 
                if ~isnan(cellValue)

                    % Convert back to old cell value
                    tData{r,c} = prev;
                    set(hObject,'data',tData);

                    % It is a number and we don't allow that!
                    nb_errorWindow('The edited variable name is not valid. Revert to old')
                    return

                end

                % Rename and update table (remember that the object also get 
                % sorted) (see the set.data method)
                try
                    gui.data = rename(gui.data,'variable',prev,new);
                catch Err

                    % Convert back to old cell value
                    tData{r,c} = prev;
                    set(hObject,'data',tData);

                    nb_errorWindow('The edited variable name is not valid. Revert to old. Error: ', Err)
                    return

                end

                % Notify that changes has been made. This will create a backup, so
                % undo and redo works
                notify(gui,'updatedData')
                gui.changed = 1;

            elseif r > objSize(gui.data,1)

                % Convert back to old cell value
                tData{r,c} = prev;
                set(hObject,'data',tData);
                return

            else

                % Get the edited variable
                varName = tData{1,c};

                % Get date or type
                rowName = tData{r,1};

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

            end
            
        end
        
        % Notify that changes has been made. This will create a backup, so
        % undo and redo works
        notify(gui,'updatedData')
        gui.changed = 1;
        
    else
        
        % Convert back to old cell value
        prev       = event.PreviousData;
        tData{r,c} = prev;
        set(hObject,'data',tData);
        
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end
