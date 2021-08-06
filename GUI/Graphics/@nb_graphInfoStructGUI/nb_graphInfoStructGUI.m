classdef nb_graphInfoStructGUI < handle
% Description:
%
% A class for plotting a nb_graph object in a single figure, with dropdown 
% menu to select the graph to plot. This uses the GraphStruct property, 
% and can be used instead of the graphInfoStruct method.
%
% Constructor:
%
%   gui = nb_graphInfoStructGUI(plotter,parent,figureName)
% 
%   Input:
%
%   - plotter    : As a nb_graph object.
%
%   - parent     : Either a nb_GUI object or [].
%
%   - figureName : Name of the figure window. Default is ''.
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
        
        % The loaded graph object GraphStruct 
        GraphStruct   = struct();
        
        % The main GUI window handle, as an nb_GUI object.
        parent        = [];
        
        % The stored plotter object as an nb_graph_ts or 
        % nb_graph_cs object
        plotter         = [];
          
    end
    
    properties(Access=protected)
        
        % Menu handles
        %----------------------------------------------------------
        
        graphMenu       = [];
        propertiesMenu  = [];
           
    end
    
    methods
        
        function gui = nb_graphInfoStructGUI(plotter,parent,figureName)
        % Constructor
        
            if nargin < 3
                figureName = '';
                if nargin < 2
                    parent = [];
                end
            end
            gui.figureName = figureName;
        
            if ~isa(plotter,'nb_graph')
                error([mfilename ':: The plotter input must be an object of class nb_graph.'])
            end
            gui.parent         = parent;
            gui.plotter        = copy(plotter);
            gui.plotter.parent = parent;
            
            % Create the main graph GUI window
            makeGUI(gui);
            
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
