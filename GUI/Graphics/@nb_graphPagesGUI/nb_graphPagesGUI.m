classdef nb_graphPagesGUI < handle
% Description:
%
% A class for plotting a nb_graph in a single figure, with 
% dropdown menu to select the page of the data to plot.
%
% Constructor:
%
%   gui = nb_graphPagesGUI(plotter,parent,figureName)
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
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    
    properties
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Extra name of figure
        figureName    = '';
        
        % The loaded graph object GraphStruct 
        data          = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent        = [];
        
        % The stored plotter object as an nb_graph_ts or 
        % nb_graph_cs object
        plotter         = [];
        
        % Size of figure window.
        position        = [];
          
    end
    
    properties(Access=protected)
        
        % Menu handles
        %----------------------------------------------------------
        annotationMenu  = [];
        graphMenu       = [];
        propertiesMenu  = [];
           
    end
    
    methods
        
        function gui = nb_graphPagesGUI(plotter,parent,figureName,position)
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
            gui.figureName = figureName;
            gui.position   = position;
        
            if isa(plotter,'nb_dataSource')
                if isa(plotter,'nb_ts')
                    plotter = nb_graph_ts(plotter);
                elseif isa(plotter,'nb_cs') 
                    plotter = nb_graph_cs(plotter);
                else % nb_data
                    plotter = nb_graph_data(plotter);
                end
            elseif ~isa(plotter,'nb_graph') && ~isa(plotter,'nb_table_data_source') 
                error([mfilename ':: The plotter input must be an object of class nb_graph or nb_table_data_source.'])
            end
            if ~isscalar(plotter)
                error([mfilename ':: The plotter input must be a scalar nb_graph or nb_table_data_source object.'])
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
