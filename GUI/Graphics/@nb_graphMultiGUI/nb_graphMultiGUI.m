classdef nb_graphMultiGUI < handle
% Description:
%
% A class for plotting a vector of nb_graph objects in a single
% figure, with dropdown menu to select the graph to plot.
%
% Constructor:
%
%   gui = nb_graphMultiGUI(plotter,parent,figureName)
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
        
        % Selected page to graph
        page          = 1;
        
        % The main GUI window handle, as an nb_GUI object.
        parent        = [];
        
        % The stored plotter object as a vector of nb_graph objects
        plotter       = [];
          
    end
    
    properties(Access=protected)
        
        % Menu handles
        %----------------------------------------------------------
        annotationMenu  = [];
        axesContextMenu = [];
        axesHandle      = [];
        dataMenu        = [];
        graphMenu       = [];
        propertiesMenu  = [];
           
    end
    
    methods
        
        function gui = nb_graphMultiGUI(plotter,parent,figureName)
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
            for ii = 1:numel(gui.plotter)
                gui.plotter(ii).parent = parent;
            end
            
            % Get the legend information and set the colors property
            for kk = 1:numel(gui.plotter)
                plotterT = gui.plotter(kk);
                updateLegendInformation(plotterT);
                if isempty(plotterT.colors)
                    vars   = [plotterT.variablesToPlot, plotterT.variablesToPlotRight];
                    colorO = plotterT.colorOrder;
                    if iscell(colorO)
                        colorO = nb_plotHandle.interpretColor(colorO);
                    end
                    colorOR = plotterT.colorOrderRight;
                    if iscell(colorOR)
                        colorOR = nb_plotHandle.interpretColor(colorOR);
                    end
                    colorO = [colorO; colorOR]; %#ok<AGROW>
                    if isempty(colorO)
                       colorO = nb_defaultColors(length(vars));
                    end
                    colors = cell(1,length(vars)*2);
                    for ii = 1:length(vars)
                        colors{ii*2 - 1} = vars{ii};
                        colors{ii*2    } = colorO(ii,:);
                    end
                    plotterT.colors = colors;
                end
            end
            
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
