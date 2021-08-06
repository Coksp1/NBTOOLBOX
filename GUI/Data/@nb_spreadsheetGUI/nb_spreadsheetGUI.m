classdef nb_spreadsheetGUI < handle
% Description:
%
% A class for the spreadsheet view of the data
%
% Superclasses:
%
% handle
% 
% Subclasses:
%
% nb_spreadsheetAdvGUI
%
% Constructor:
%
%   gui = nb_spreadsheetGUI(parent,varargin)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - data     : The data to display in the spreadsheet. As a nb_data, 
%                nb_ts or nb_cs object.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_spreadsheetGUI object.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Date of the created table of the spreadsheet. As a nb_data, nb_ts
        % or nb_cs object
        data                = [];
        
        % Name of loaded dataset
        dataName            = '';
       
        % Set the editability of the table
        editMode      = 0;
        
        % Handle to the figure window of the GUI
        figureHandle        = [];
        
        % Name of figure
        figureName          = 'Spreadsheet:';
        
        % When the dataset is opened in a graph window we need an indicator
        % of this. 1 if opened in graph GUI, otherwise 0 (default).
        openElsewhere       = 0;
        
        % Set if should be possible to load up a new dataset to
        % the current window. Default is yes (1).
        loadMode            = 1;
        
        % The displayed page in the table of the data object.
        page                = 1;
        
        % The main GUI window handle, as an nb_GUI object.
        parent              = [];

        % The number of digits to display in the spreadsheet
        precision           = '4';
        
        % Text poping up in the manu, when openElsewhere is set to 1.
        % Default is 'Save to Graph'.
        saveToMenuText      = 'Save to Graph';
        
        % Sets the table type. 'Freeze' or 'Unfreeze'
        tableType           = 'Freeze';
        
        % Transformed data, as an nb_ts or nb_cs object
        transData           = [];
        
    end
    
    properties (Access=protected,Hidden=true)
        
        % Indicator if the data of the GUI have been changed but 
        % not saved
        changed             = 0;
        
        % Handle to the data menu
        dataMenu            = [];
        
        % The handle to the dataset menu
        datasetMenu         = [];
        
        % Handle to the help menu
        helpMenu            = [];
        
        % Selected cells of the uitable object
        selectedCells       = [];
        
        % Selected cells of the uitable object, not interpreted.
        selectedCellsU      = [];
        
        % Handle to the statistics menu
        statisticsMenu      = [];
        
        % Handle to the nb_uitable object
        table               = [];
        
        % Handle to the view window
        viewMenu            = [];
        
        % Handle to the pagename box
        pageBox             = [];
        
        % Handle to the numObs box
        numObsBox           = [];
        
        % Handle to the moment box
        momentTypeBox       = [];
        momentBox           = [];
        
        % Handle to old name of spreadsheet
        oldSaveName         = [];
        
        % Handle to old strings in boxes
        oldString           = cell(3,1);
        
    end
    
    events
        
        updatedData
        savedData 
        selectionChanged
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_spreadsheetGUI(parent,data,openElsewhere,saveToMenuText)
        % Constructor
        
            if nargin < 4
                saveToMenuText = '';
                if nargin < 3
                    openElsewhere = 0;
                    if nargin < 2
                        data = nb_ts;
                    end
                end
            end
        
            % Assign parent
            gui.parent        = parent;
            gui.openElsewhere = openElsewhere;
            if ~isempty(saveToMenuText)
                gui.saveToMenuText = saveToMenuText;
            end
            
            % Make GUI window
            makeWindow(gui);
            gui.data = data;
            addlistener(gui,'selectionChanged',@gui.calculateMomentCallback);
            
        end
        
        function set.data(gui,propertyValue)
            
            hasNewType      = ~isa(propertyValue,class(gui.data));
            shouldUpdateGUI = hasNewType || isempty(gui.data);
            
            gui.data = propertyValue;
            updateTable(gui);
            
            if isempty(gui.datasetMenu) %#ok<MCSUP>
                makeGUI(gui);
            else
                if shouldUpdateGUI
                    % The menu can change dependent on the type of data
                    % stored by the spreadsheet, so if we switch data
                    % type we update the menu components
                    updateGUI(gui);
                else
                    enableGUI(gui);
                end
            end
 
        end
        
        function set.dataName(gui,value)
            
            gui.dataName = value;
            
            % Update the figure name, so the dataset name is 
            % displayed
            assignDataNameToFigureName(gui);
            
        end
        
        function set.figureName(gui,propertyValue)
            
            gui.figureName = propertyValue;
                    
            % Update the name of the window
            updateFigureName(gui);
            
        end
        
        function set.loadMode(gui,propertyValue)
            
            gui.loadMode = propertyValue;
            enableLoadMenu(gui);
            
        end
        
        function set.changed(gui,propertyValue)
           
            if propertyValue == gui.changed
                return
            end

            gui.changed = propertyValue;

            % Add a dot if changed is set to 1, else
            % remove if it exists
            if propertyValue

                current = get(gui.figureHandle,'name'); %#ok<MCSUP>
                newName = [current '*'];
                set(gui.figureHandle,'name',newName); %#ok<MCSUP>

            else

                current = get(gui.figureHandle,'name'); %#ok<MCSUP>
                index   = strfind(current,'*');
                if ~isempty(index)
                    current = strrep(current,'*','');
                    set(gui.figureHandle,'name',current); %#ok<MCSUP>
                end

            end
            
        end
        
        function set(gui,varargin)
                
            for jj = 1:2:size(varargin,2)

                propertyName  = varargin{jj};
                propertyValue = varargin{jj + 1};

                if ischar(propertyName)

                    switch lower(propertyName)

                        case 'page'

                            if isnumeric(propertyValue)
                                gui.page = propertyValue;
                                updateTable(gui);
                            else
                                error([mfilename ':: The input after ''page'' must be a integer.']);
                            end

                    end

                end

            end

        end
        
        function set.editMode(gui,propertyValue)
            
            gui.editMode = propertyValue;
            updateTable(gui);
            
        end
        
        function dataObj = getDataObject(gui)
            
            if isa(gui.data,'nb_modelDataSource')
                try
                    dataObj = fetch(gui.data);
                catch
                    nb_errorWindow('Could not fetch from the SMART database.')
                    return
                end
            else
                if isempty(gui.transData)
                    dataObj = gui.data;
                else
                    dataObj = gui.transData;
                end
            end
            
        end
                
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
        
        varargout = pca(varargin)
        
        varargout = hidePageBox(varargin)
        
        varargout = deleteOldFile(varargin)
        
        varargout = renameSpreadsheet(varargin)
        
        varargout = cointegration(varargin)
        
        varargout = autocorr(varargin)
        
        varargout = unitRoot(varargin)
        
        varargout = addContextMenu(varargin)
        
        varargout = close(varargin)
        
        varargout = copySelected(varargin)
        
        varargout = copySelectedWith(varargin)
        
        varargout = copyTable(varargin)
        
        varargout = createTable(varargin)
        
        varargout = editNotes(varargin)
        
        varargout = getSelectedCells(varargin)
        
        varargout = graph(varargin)
        
        varargout = graphSelected(varargin)
        
        varargout = makeGUI(varargin)
        
        varargout = makeWindow(varargin)
        
        varargout = setPage(varargin)
        
        varargout = updateEditMode(varargin)
        
        varargout = updateFigureName(varargin)
        
        varargout = updateTable(varargin)
        
        varargout = updateTableType(varargin)

        varargout = rand(varargin)
        
        varargout = export(varargin)
        
        varargout = write(varargin)
        
        varargout = save(varargin)
        
        varargout = saveAs(varargin)
        
        varargout = updateGUI(varargin)
        
        varargout = convert(varargin)
        
        varargout = correlation(varargin)
        
        varargout = covariance(varargin)
        
        varargout = createVariable(varargin)
        
        varargout = createType(varargin)
        
        varargout = deleteVariable(varargin)
        
        varargout = deleteType(varargin)
        
        varargout = egrowth(varargin)
        
        varargout = epcn(varargin)
        
        varargout = exp(varargin)
        
        varargout = getRawData(varargin)
        
        varargout = growth(varargin)
        
        varargout = log(varargin)
        
        varargout = merge(varargin)
        
        varargout = pcn(varargin)
        
        varargout = renamePage(varargin)
        
        varargout = renameVariable(varargin)
        
        varargout = selectMethod(varargin)
        
        varargout = summaryStatistics(varargin)
        
        varargout = update(varargin)
        
        varargout = nextPage(varargin)
        
        varargout = previousPage(varargin)
        
        varargout = getSource(varargin)
        
        varargout = editFreezeCellCallback(varargin)
        
        varargout = editUnfreezeCellCallback(varargin)
        
        varargout = editableCallback(varargin)
        
    end
    
    
    methods(Static=true,Access=protected,Hidden=true)
        
        function rowNames = createDefaultFirstColumn(numOfRows)
        % Get the first column table in non-freeze mode
        
            rowNames = 1:numOfRows;
            rowNames = rowNames(:);
            rowNames = int2str(rowNames);
            rowNames = cellstr(rowNames);
            
        end
        
        function colNames = createDefaultFirstRow(numOfCols)
        % Get the first column table in non-freeze mode
        
            colNames = 1:numOfCols;
            colNames = colNames(:);
            colNames = int2str(colNames);
            colNames = cellstr(colNames);
            
        end
        
    end
    
end

