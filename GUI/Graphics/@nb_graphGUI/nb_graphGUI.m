classdef nb_graphGUI < handle
% Description:
%
% The superclass for the nb_graph_dataGUI, nb_graph_tsGUI and 
% nb_graph_csGUI classes.
%
% Constructor:
%
%   Not possible to construct an nb_graphGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % If set to 1 the paste context menu is added to the GUI,
        % otherwise it will not be added.
        contextMenu             = 0;
        
        % Current graph that can be edited. This will be set by 
        % changeGraphCallback in the case a advanced graph consists of
        % a panel of two nb_graph objects.
        currentGraph            = 1;
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle            = [];
        
        % The page plotted
        page                    = 1;
        
        % The main GUI window handle, as an nb_GUI object.
        parent                  = [];
        
        % The stored plotter object as a nb_graph_obj
        plotter                 = [];
        
        % The stored plotter object as an nb_graph_adv object
        plotterAdv              = [];
        
        % Name of the loaded plotter object
        plotterName             = '';
        
        % Indicator if this is a table or not
        table                   = false;
        
        % Stores the default template to use for graphs.
        template                = '';
        
        % Type of graph GUI to create. Either {'normal'} or 
        % 'advanced'
        type                    = 'normal';
        
    end
    
    properties(Access=protected)
        
        % Handle to the uicontextmenu object of the graph
        axesContextMenu     = [];  
        
        % Menu handles
        %----------------------------------------------------------
        
        advancedMenu    = [];
        annotationMenu  = [];
        changed         = 0;
        dataMenu        = [];
        graphMenu       = [];
        languageMenu    = [];
        helpMenu        = [];
        propertiesMenu  = [];
        templateMenu    = [];
        
        % Old save name
        oldSaveName     = [];
        
    end
    
    methods
        
        function gui = nb_graphGUI(parent,type,contextMenu,table,template)
        % Constructor
        
            if nargin < 5
                template = '';
                if nargin < 4
                    table = false;
                    if nargin < 3
                        contextMenu = 0;
                        if nargin < 2
                            type = 'normal';
                        end
                    end
                end
            end
            if isempty(template)
                if strcmpi(type,'normal')
                    template = parent.settings.defaultNormalTemplate;
                else
                    template = parent.settings.defaultAdvancedTemplate;
                end
            end
        
            if isa(parent,'nb_combineForecastGUI') || isa(parent,'nb_aggregateForecastGUI')
                parent = parent.parent;
            end
            gui.parent      = parent;
            gui.contextMenu = contextMenu;
            gui.template    = template;
            gui.type        = type;
            gui.table       = table;
            
            % Create the main graph GUI window
            makeGUI(gui);
            
        end
        
        function set.plotterName(gui,value)
            
            gui.plotterName = value;
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
    
    
    methods(Access=protected,Hidden=true)
        
        varargout = renameGraph(varargin)
        varargout = makeGUI(varargin)
        varargout = close(varargin)
        varargout = export(varargin)
        varargout = save(varargin)
        varargout = saveAs(varargin)
        varargout = loadData(varargin)
        varargout = mergeOrReset(varargin)
        varargout = mergeCallback(varargin)
        varargout = resetCallback(varargin)
        varargout = setFigureName(varargin)
        varargout = setFigureTitle(varargin)
        varargout = setFooter(varargin)
        varargout = setForecastDate(varargin)
        varargout = setRemovedVariables(varargin)
        varargout = setNumberingOptions(varargin)
        varargout = setRoundOffCallback(varargin)
        varargout = copyToClipboard(varargin)
        varargout = defaultPlotter(varargin)
        varargout = resetDataSource(varargin)
        varargout = addMergedData(varargin)
        varargout = changedCallback(varargin)
        varargout = enableUIComponents(varargin)
        varargout = removeStar(varargin)
        varargout = saveObjectCallaback(varargin)
        varargout = printFigure(varargin)
        varargout = helpFileCallback(varargin)
        varargout = newTemplateCallback(varargin)
        varargout = setTemplateCallback(varargin)
        varargout = saveTemplateCallback(varargin)
        varargout = helpTemplateCallback(varargin)
        varargout = helpAdvancedMenuCallback(varargin)
                 
    end
       
end
