classdef nb_graph_subplotGUI < handle
% Description:
%
% This class makes a GUI for creating a graph with the nb_graph_subplot 
% class interacivly.
%
% Constructor:
%
%   gui = nb_graph_subplotGUI(parent,plotter)
% 
%   Input:
%
%   - parent  : A nb_GUI object or empty.
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
       
        % Indicator for changes made to the graph panel.
        changed         = 0;
        
        % Handle to the nb_figure object
        figureHandle        = [];
        
        % Parent as an nb_GUI object
        parent              = [];
        
        % An nb_graph_subplot object
        plotter             = [];
        
        % Save name of panel
        plotterName         = '';
        
    end
    
    properties (Access=protected)
       
        advancedMenu        = [];
        fileMenu            = [];
        panelMenu           = [];
        propertiesMenu      = [];
        
    end
    
    methods
        
        function gui = nb_graph_subplotGUI(parent,plotter)
        % Constructor
        
            if nargin < 2
                plotter = [];
            end
        
            if nargin == 1 && isa(parent,'nb_graph_subplot')
                plotter = parent;
                parent  = [];
            end
            gui.parent = parent;
            if ~isempty(plotter)
                if isa(plotter,'nb_graph_subplot')
                    gui.plotter = plotter;
                else
                    error([mfilename ':: The input plotter must be an nb_graph_subplot object.'])
                end
            else
                createDefaultPlotter(gui);
            end
            gui.plotter.parent = gui.parent;
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
        
       varargout = makeGUI(varargin) 
       varargout = createDefaultPlotter(varargin)
       varargout = addContextMenu(varargin)
       varargout = changedCallback(varargin)
       varargout = close(varargin)
       varargout = copy(varargin)
       varargout = copyToClipboard(varargin)
       varargout = export(varargin)
       varargout = paste(varargin)
       varargout = save(varargin)
       varargout = saveAs(varargin)
       varargout = saveObjectCallback(varargin)
       varargout = updateGraph(varargin)
        
    end
    
end
