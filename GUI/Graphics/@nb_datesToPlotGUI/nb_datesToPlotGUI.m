classdef nb_datesToPlotGUI < handle
% Description:
%
% This class makes a GUI for dates vs dates plot.
%
% Constructor:
%
%   gui = nb_datesToPlotGUI(plotter)
% 
%   Input:
%
%   - plotter : As an nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Handle to the graph object. As an nb_graph object.
        plotter       = [];
        
    end

    properties (Access = protected)
        
        panelHandle         = [];
        varpopup            = [];
        
    end

    events
        
        changedGraph
        changedGraphType
        
    end
    
    methods
        
        function gui = nb_datesToPlotGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)

        varargout = activateOptionsCallback(varargin)
        
        varargout = optionsCallback(varargin)
        
        varargout = selectDates(varargin)
        
        varargout = selectVariables(varargin)
        
    end
    
end
