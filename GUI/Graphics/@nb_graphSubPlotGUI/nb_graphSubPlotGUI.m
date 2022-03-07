classdef nb_graphSubPlotGUI < handle
% Description:
%
% A class for plotting a nb_graph object in a single figure, with dropdown 
% menu to select the graph to plot. This can be used instead of the 
% graphSubPlots method.
%
% Constructor:
%
%   gui = nb_graphSubPlotGUI(object,parent,figureName,position)
% 
%   Input:
%
%   - plotter    : As a nb_graph object or a nb_dataSource objects.
%
%   - parent     : Either a nb_GUI object or [].
%
%   - figureName : Name of the figure window. Default is ''.
%
%   - position   : Size of figure window. Default is [40,15,186.4,43].
% 
%   Output:
% 
%   - gui        : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    
    properties
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Extra name of figure
        figureName    = '';
        
        % The main GUI window handle, as an nb_GUI object.
        parent        = [];
        
        % The stored plotter object as an nb_graph_ts or 
        % nb_graph_cs object
        plotter         = [];
        
        % Size of figure window.
        position        = [];
        
        % Set the subplot size. As a 1x2 double. 
        subPlotSize     = [2,2]; 
        
        % Variables to plot
        vars            = {};
        
        % Variables to plot on x-axis (nb_graph_data)
        varsX           = {};
        
    end
    
    properties(Access=protected)
        
        % Menu handles
        %----------------------------------------------------------
        
        graphMenu       = [];
        propertiesMenu  = [];
           
    end
    
    methods
        
        function gui = nb_graphSubPlotGUI(object,parent,figureName,position)
        % Constructor
        
            if nargin < 4
                position = [];
                if nargin < 3
                    figureName = '';
                    if nargin < 2
                        parent = [];
                    end
                end
            end
        
            gui.position   = position;
            gui.figureName = figureName;
            gui.parent     = parent;
            if isa(object,'nb_graph')
                gui.plotter = copy(object);
            else
            
                if isa(object,'nb_ts')
                    gui.plotter = nb_graph_ts(object);
                elseif isa(object,'nb_data')
                    gui.plotter = nb_graph_data(object);
                else
                    gui.plotter = nb_graph_cs(object);
                end
                
            end
            gui.plotter.parent = parent;
            gui.subPlotSize    = gui.plotter.subPlotSize;
            
            % Create the main graph GUI window
            gui.makeGUI();
            
        end
        
    end
    
    
    methods(Access=protected,Hidden=true)
        varargout = makeGUI(varargin)
        varargout = changeGraph(varargin)
        varargout = export(varargin)
        varargout = spreadsheet(varargin)
        varargout = copyToClipboard(varargin)
        varargout = printFigure(varargin)
        varargout = nextGraphCallback(varargin)
        varargout = previousGraphCallback(varargin)
        varargout = revertSize(varargin)     
    end
       
end
