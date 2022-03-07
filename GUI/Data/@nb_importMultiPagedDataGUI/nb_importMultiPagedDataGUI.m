classdef nb_importMultiPagedDataGUI < handle
% Description:
%
% A class for the import multi-paged data to main GUI.
%
% Constructor:
%
%   gui = nb_importMultiPagedDataGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As a  
%              nb_importMultiPagedDataGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        
        % uicontrol pushbutton.
        allButton           = [];
        
        % Text part of data, used in finding variables and obs/dates/types
        cellString          = [];
        
        % Handle to the Excel application
        excel               = [];
        
        % Advanced import window
        importWindow        = [];
        
        % Initial selection window
        initSelectPanel     = [];
        
        % Editbox to give the datset a different name than the origional
        % file
        nameBox             = [];
        
        % Sheet selection boxes
        initSheetSelectBox  = [];
        
        % List of excel sheet names
        sheetList           = [];
        
        % A listbox of the sheets to import.
        sheets              = [];
        
        % Sorting
        sortButton          = [];
        
        % Table for preview of data for each panel
        initTable           = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_importMultiPagedDataGUI(parent)
        % Constructor 
        
            gui.parent = parent;
            importDialog(gui)
            
        end
        
        function set.figureName(gui,propertyValue)
            
            gui.figureName = propertyValue;
                    
            % Update the name of the window
            updateFigureName(gui);
            
        end
        
        function updateTable(gui)
            
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
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        varargout = allCallback(varargin)
        varargout = closeWindow(varargin)
        varargout = selectBoxCallback(varargin);
        varargout = makeGUI(varargin)
        varargout = finishCallback(varargin)
        varargout = importDialog(varargin)
        varargout = exitGUI(varargin)       
        varargout = overwrite(varargin)
        varargout = rename(varargin)
        varargout = loadOptionsWhenExist(varargin)
        
    end
    
end

