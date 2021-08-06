classdef nb_fanChartGUI < handle
% Description:
%
% A GUI to add fan chart to graph.
%
% Constructor:
%
%   gui = nb_fanChartGUI(plotter,type)
% 
%   Input:
%
%   - plotter : An object of class nb_graph.
%
%   - type    : Type of fan chart. Either 'default','dataset' or 
%               'variable'.
% 
%   Output:
% 
%   - gui    : The handle to the object. 
% 
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_graph_ts object
        plotter             = [];
        
        % Type of fan chart. Either 'default','dataset' or 
        % 'variable'.
        type                = '';
        
    end
    
    properties(Access=protected)
        
        fanDataset   = nb_ts;
        fanVariables = {};
        
        panelHandle1 = [];
        panelHandle2 = [];
        
        handle1      = [];
        handle2      = [];
        handle3      = [];
        handle4      = [];
        handle5      = [];
        handle6      = [];
        handle7      = [];
        handle8      = [];
        handle9      = [];
        handle10     = [];
        handle11     = [];
        
        table       = {};
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_fanChartGUI(plotter,type)
        % Constructor
        
            gui.plotter = plotter;
            gui.type    = type;
            
            % Make the GUI
            switch lower(type)
                case 'default'
                    makeDefaultGUI(gui);
                case 'dataset'
                    makeDatasetGUI(gui);
                case 'variable'
                    makeFanVariablesGUI(gui);
                case 'remove'
                    makeRemoveGUI(gui);
            end
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeDefaultGUI(varargin)
        
        varargout = makeRemoveGUI(varargin)
        
        varargout = makeDatasetGUI(varargin)
        
        varargout = makeFanVariablesGUI(varargin)
        
        varargout = changeTable(varargin)
        
        varargout = finishFanDataset(varargin)
        
        varargout = finishFanVariables(varargin)
        
        varargout = propertiesPanel(varargin)
        
        varargout = selectDatasetPanel(varargin)
        
        varargout = selectVariablesPanel(varargin)
        
        varargout = setFanDataset(varargin)
        
        varargout = setFanVariables(varargin)
        
    end
    
end
