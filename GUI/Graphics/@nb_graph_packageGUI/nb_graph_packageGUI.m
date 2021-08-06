classdef nb_graph_packageGUI < handle
% Description:
%
% A class for interactivly creating graph packages.
%
% Constructor:
%
%   gui = nb_graph_packageGUI(parent,package)
% 
%   Input:
%
%   - parent  : An nb_GUI object.
%
%   - package : An nb_graph_package object.
% 
%   Output:
% 
%   - gui    : An nb_graph_packageGUI object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Indicator for changes made to the graph package.
        changed         = 0;
        
        % As an nb_graph_package object
        package         = [];
        
        % Save name of package
        packageName     = '';
        
        % The parent of the window as an nb_GUI object
        parent          = [];
        
        % Template used when producing graphs
        template        = 'current';
        
        % Templates to choose from
        templates       = {};
         
    end
    
    properties(Access=protected,Hidden=true)
        
        % GUI handles
        figureHandle    = [];
        graphMenu       = [];
        graphList       = [];
        helpMenu        = [];
        methodsMenu     = [];
        packageMenu     = [];
        propertiesMenu  = [];
        templateMenu    = [];
        
        % Handle to old save name (future reference)
        oldSaveName     = [];
        
    end
    
    events 
       
        changedGraphs
        
    end
    
    methods
        
        function gui = nb_graph_packageGUI(parent,package)
            
            gui.parent    = parent;
            gui.package   = package;
            updateTemplates(gui);
            
            makeGUI(gui);
            
            % Assign listener
            addlistener(parent,'advancedGraphChanged',@gui.syncPackage);
            addlistener(gui,'changedGraphs',@gui.updateGUI);
            
        end
        
        function set.packageName(gui,value)
            
            gui.packageName = value;
            current         = get(gui.figureHandle,'name'); %#ok<MCSUP>
            index           = strfind(current,':');
            if length(index) > 1
                newName = [current(1:index(end)) ' ' value];
            else
                newName = [current ': ' value];
            end
            set(gui.figureHandle,'name',newName);%#ok<MCSUP>
            
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
                
    end
    
    methods(Static=true)
        function help()
        msg = 'test';
        nb_helpWindow(msg)
        end
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = deleteOldPackage(varargin)
        
        varargout = excelChangeLog(varargin)
        
        varargout = renamepackage(varargin)
    
        varargout = makeGUI(varargin)
        
        varargout = syncPackage(varargin)
        
        varargout = add(varargin)
        
        varargout = chapter(varargin)
        
        varargout = close(varargin)
        
        varargout = deleteCallback(varargin)
        
        varargout = export(varargin)
        
        varargout = packageChangedCallback(varargin)
        
        varargout = preview(varargin)
        
        varargout = reorder(varargin)
        
        varargout = save(varargin)
        
        varargout = saveAs(varargin)
        
        varargout = saveForMPR(varargin)
        
        varargout = saveObjectCallback(varargin)
        
        varargout = saveToExcel(varargin)
        
        varargout = saveToPDF(varargin)
        
        varargout = setRoundoff(varargin)
        
        varargout = setZeroLowerBound(varargin)
        
%        varargout = setExcelStyle(varargin)
        
        varargout = start(varargin)
        
        varargout = subtitle(varargin)
        
        varargout = title(varargin)
        
        varargout = update(varargin)
        
        varargout = viewInfoSpreadsheetCallback(varargin)
        
        varargout = helpTemplateGPCallback(varargin)
        
        varargout = helpMethodsGPCallback(varargin)
        
        varargout = helpPropertiesGPCallback(varargin)
        
    end
    
end
