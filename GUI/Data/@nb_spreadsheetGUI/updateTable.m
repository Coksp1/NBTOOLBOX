function updateTable(gui)
% Syntax:
%
% updateTable(gui)
%
% Description:
%
% Part of DAG. Update the table
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Default setting
    rows = 50;
    cols = 25;

    % Get table handle
    tableH = gui.table;

    % Get updated (transformed) data object
    dataObj = getDataObject(gui);
    if isempty(dataObj)
        % The dataset is empty, create default table
        createTable(gui)
        set(gui.dataMenu,'enable','off');
        return
    end
    
    % Set the pagebox to match the new data
    try
        gui.oldString{1} = dataObj.dataNames{gui.page};
    catch %#ok<CTCH>
        gui.page         = 1;
        gui.oldString{1} = dataObj.dataNames{gui.page};
    end
    set(gui.pageBox,'string',gui.oldString{1},...
        'TooltipString', gui.oldString{1},...
        'callback',      {@nb_lockEditBox,gui.oldString{1}});
    
    if isa(dataObj,'nb_cs')
        gui.oldString{2} = num2str(dataObj.numberOfTypes);
    elseif isa(dataObj,'nb_cell')
        gui.oldString{2} = num2str(size(dataObj.data,1));
    else
        gui.oldString{2} = num2str(dataObj.numberOfObservations);  
    end
    set(gui.numObsBox,'string',gui.oldString{2},...
        'TooltipString', gui.oldString{2},...
        'callback',      {@nb_lockEditBox,gui.oldString{2}});
    
    if isa(dataObj,'nb_ts')
        rowNamesObj = dates(dataObj);
        rowsD       = dataObj.numberOfObservations;
    elseif isa(dataObj,'nb_bd')
        rowNamesObj = dates(dataObj,'','stripped');
        rowsD       = size(rowNamesObj,1);
    elseif isa(dataObj,'nb_data')
        rowNamesObj = observations(dataObj,'cellstr');
        rowsD       = dataObj.numberOfObservations;
    elseif isa(dataObj,'nb_cell')
        gui.tableType = 'unfreeze';
        set(findobj(gui.viewMenu,'label','Freeze'),'checked','off');
        set(findobj(gui.viewMenu,'label','Unfreeze'),'checked','on');
    else
        rowNamesObj = dataObj.types';
        rowsD       = dataObj.numberOfTypes; 
    end
    
    if isa(gui.data,'nb_cell')
        rowsD = size(dataObj.data,1);
        colsD = size(dataObj.data,2);
    else
        colsD = dataObj.numberOfVariables;
        if isDistribution(dataObj)
            dataT = asCell(dataObj);
            dataT = dataT(2:end,2:end,gui.page);
        else
            if isa(dataObj,'nb_bd')
                dataT = double(dataObj,'stripped');
            else
                dataT = double(dataObj);
            end
            dataT = dataT(:,:,gui.page);
            dataT = nb_double2cell(dataT,['%.' gui.precision 'f']);
        end
        vars = dataObj.variables;
    end
    
    % Then update the nb_uitable handle
    %--------------------------------------------------------------
    switch lower(gui.tableType)

        case 'freeze'

            colNames   = vars;
            rowNames   = rowNamesObj;
            colForm    = cell(1,colsD);
            if gui.precision == 4
                colForm(:) = {'numeric'};
            else
                colForm(:) = {'char'};
            end

            set(tableH,...
                'columnNamesOnly',  true,...
                'data',             dataT,...
                'columnName',       colNames,...
                'columnFormat',     colForm,...
                'rowName',          rowNames);

        case 'unfreeze'

            if rowsD + 1 > rows
                rows = rowsD;
            end

            if colsD + 1 > cols
                cols = colsD;
            end

            dataOfTable = cell(rows ,cols);
            if ~isa(gui.data,'nb_cell')
                dataOfTable(:,:)                     = {''};                  
                dataOfTable(2:rowsD + 1,2:colsD + 1) = dataT;
                dataOfTable(2:rowsD + 1,1)           = rowNamesObj;
                dataOfTable(1,2:colsD + 1)           = vars;
            else
                dataOfTable(1:rowsD,1:colsD) = dataObj.cdata(:,:,gui.page);
            end

            rowNames = nb_spreadsheetGUI.createDefaultFirstColumn(rows);
            colNames = nb_spreadsheetGUI.createDefaultFirstRow(cols);

            colForm    = cell(1,cols);
            colForm(:) = {'char'};

            set(tableH,...
                'columnNamesOnly',  true,...
                'data',             dataOfTable,...
                'columnName',       colNames,...
                'columnFormat',     colForm,...
                'rowName',          rowNames);
           
    end
    
    % Make editable if wanted
    %-------------------------
    if gui.editMode
        
        switch lower(gui.tableType)

            case 'freeze'

                set(tableH,...
                    'columnEditable',   true(1,length(colNames)),...
                    'cellEditCallback', @gui.editFreezeCellCallback);

            case 'unfreeze'

                if isa(gui.data,'nb_cell')
                   editable = true(1,length(colNames));
                else
                   editable = [false,true(1,length(colNames)-1)];
                end
                set(tableH,...
                    'columnEditable',   editable,...
                    'cellEditCallback', @gui.editUnfreezeCellCallback);
        end
        
    else
        
        switch lower(gui.tableType)

            case 'freeze'

                set(tableH,...
                    'columnEditable',   false(1,length(colNames)),...
                    'cellEditCallback', '');

            case 'unfreeze'

                set(tableH,...
                    'columnEditable',   false(1,length(colNames)),...
                    'cellEditCallback', '');
        end
        
    end

    % Context menu
    %--------------------------------------------------------------
    addContextMenu(gui)

end
