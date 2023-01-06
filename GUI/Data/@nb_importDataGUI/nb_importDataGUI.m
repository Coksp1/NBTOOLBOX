classdef nb_importDataGUI < nb_heavyJobInterface
% Description:
%
% A class for the import data to main GUI.
%
% Constructor:
%
%   gui = nb_importDataGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As a nb_importDataGUI 
%              object.
% 
% Written by Kenneth Sæterhagen Paulsen/Eyo Herstad
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The imported data as either an nb_data, nb_ts or nb_cs object
        data                = [];
        
        % A cell with the fetched data
        dataC               = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent              = [];
        
        % Name of figure
        figureName          = 'Import:';
        
        % Name of selected file
        filename            = '';
        
        % Path of selected file
        pathname            = '';
        
        % Save name of the loaded data. As a string
        name                = '';
        
    end 
    
    properties (Access=protected,Hidden=true)
        
        % Text part of data, used in finding variables and obs/dates/types
        cellString          = [];
        
        % Handle to the Excel application
        excel               = [];
        
        % Initial selection window
        initSelectPanel     = [];
        
        % Advanced selection window
        advSelectPanel      = [];
        
        % The panel that is currently active
        currentPanel        = [];
        
        % Custom/predef range selection
        customSpec          = [];
        
        % Editbox to give the datset a different name than the origional
        % file
        nameBox             = [];
        
        % Sheet selection boxes
        initSheetSelectBox  = [];
        advSheetSelectBox   = [];
        
        % List of excel sheet names
        sheetList           = [];
        
        % Sorting
        sortButton          = [];
        sortButtonAdv         = [];
        
        % Boxes to select range for excel import
        dataSelectBox       = [];
        varSelectBox        = [];
        dateSelectBox       = [];
        
        % Choice of whether or not to transpose imported data
        transposeButton     = [];
        
        % Table for preview of data for each panel
        initTable           = [];
        advTable            = [];
        
        % nb_cell option
        nb_cellButton       = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_importDataGUI(parent)
        % Constructor 
        
            gui.parent = parent;
            importDialog(gui);
            
        end
        
        function set.figureName(gui,propertyValue)
            
            gui.figureName = propertyValue;
                    
            % Update the name of the window
            updateFigureName(gui);
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        function updateTable(gui)
           
            if isequal(gui.currentPanel,gui.initSelectPanel)
                updateInitTable(gui);
            else
                updateAdvTable(gui);
            end
            
        end
        
        function updateInitTable(gui)
            
            dataT = gui.dataC;
            numOfColumns = size(dataT,2);
            if numOfColumns > 20
                dataT = dataT(:,1:20);
            end
            if size(dataT,1) > 20
                dataT = dataT(1:20,:);
            end
            
            numOfColumns = size(dataT,2);
            colNames     = nb_xlsNum2Column(1:numOfColumns);
            set(gui.initTable,...
                'data',          dataT,...
                'rowName',       'numbered',...
                'columnName',    colNames);
            
        end
        
        function updateAdvTable(gui)
            
            dataT        = gui.dataC;
            numOfColumns = size(dataT,2);
            colNames     = nb_xlsNum2Column(1:numOfColumns);
            set(gui.advTable,...
                'data',          dataT,...
                'rowName',       'numbered',...
                'columnName',    colNames);
            
        end
        
        varargout = closeWindow(varargin)
        varargout = selectBoxCallback(varargin);
        varargout = editRangeCallback(varargin);
        varargout = transposeCallback(varargin);
        varargout = importRadioCallback(varargin);
        varargout = switchImportPanel(varargin)
        varargout = makeGUI(varargin)
        varargout = finishCallback(varargin) 
        varargout = importDialog(varargin)
        varargout = exitGUI(varargin)
        varargout = overwrite(varargin)
        varargout = rename(varargin) 
        varargout = loadOptionsWhenExist(varargin)
        
    end
    
    methods(Static=true)
        
        varargout = genColList(varargin);
        
    end
    
end

