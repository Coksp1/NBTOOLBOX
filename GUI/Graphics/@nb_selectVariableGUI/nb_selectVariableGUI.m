classdef nb_selectVariableGUI < handle
% Description:
%
% Make GUI so that the user can select the variables plotted in the graph.
%
% Constructor:
%
%   gui = nb_selectVariableGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen  
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors, when parent is empty.
        defaultColors   = nb_defaultColors();
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Handle to the graph object. As an nb_graph object.
        plotter       = [];
         
    end
    
    properties(Access=protected)
        
        % Handle to the button group
        buttonGroup     = [];
        
        % Handle to a edit box
        editbox1        = [];
        
        % Handle to a edit box
        editbox2        = [];
        
        % Handle to a edit box
        editbox3        = [];
        
        % Handle to a edit box
        editbox4        = [];
        
        % Indicator if the GUI is beeing initialized
        initialized     = 1;
        
        % Handle to the variable selection pop-up menu
        popupmenu1      = [];
        
        % Handle to the plot type selection pop-up menu
        popupmenu2      = [];
        
        % Handle to a pop-up menu
        popupmenu3      = [];
        
        % Handle to a pop-up menu
        popupmenu4      = [];
        
        % Handle to a pop-up menu
        popupmenu5      = [];
        
        % Handle to a pop-up menu
        popupmenu6      = [];
        
        % Handle to a pop-up menu
        popupmenu7      = [];
        
        % Handle to a pop-up menu
        popupmenu8      = [];
        
        % Handle to a pop-up menu
        popupmenu9      = [];
        
        % Handle to a pop-up menu (scatter marker type)
        popupmenu10     = [];
        
        % Handle to a pop-up menu
        popupmenu11      = [];
        
        % Handle to a radio button
        radiobutton1    = [];
        
        % Handle to a checkbox
        checkbox1       = [];
        
        % Handle to a checkbox
        checkbox2       = [];
        
        % Which side to plot the current scatter plot.
        scatterSide     = 'left';
        
        % Handle to the properties panel
        uip             = [];
           
    end
    
    events 
       
        changedGraph
        
    end
    
    methods
        
        function gui = nb_selectVariableGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Create the main graph GUI window
            switch gui.plotter.plotType
                
                case 'candle'

                    gui.makeCandleGUI();

                case 'scatter'

                    gui.makeScatterGUI();
                    
                otherwise
                    
                    gui.makeGUI();
                    
            end
            
        end
          
    end
    
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = updateGUI(varargin)
        
        varargout = linePanel(varargin)
        
        varargout = barAndAreaPanel(varargin)
        
        varargout = selectVarPlotType(varargin)
        
        varargout = updatePanel(varargin)
        
        varargout = changeVariable(varargin)
        
        varargout = setPlotOption(varargin)
        
        varargout = selectColor(varargin)
        
        varargout = selectLineStyle1(varargin)
        
        varargout = splitLine(varargin)
        
        varargout = selectLineStyle2(varargin)
        
        varargout = changeSplitDate(varargin)
        
        varargout = setLineWidth(varargin)
        
        varargout = selectMarker(varargin)
        
        varargout = setMarkerSize(varargin)
        
        varargout = makeScatterGUI(varargin)
        
        varargout = changeScatterGroup(varargin)
        
        varargout = updateScatterGUI(varargin)
        
        varargout = scatterSelectSideToPlot(varargin)
        
        varargout = scatterAddGroup(varargin)
        
        varargout = scatterDeleteGroup(varargin)
        
        varargout = scatterPanel(varargin)
        
        varargout = selectScatterVariable1(varargin)
        
        varargout = setScatterEndDate(varargin)
        
        varargout = makeCandleGUI(varargin)
        
        varargout = selectCloseVariable(varargin)
        
        varargout = selectOpenVariable(varargin)
        
        varargout = selectHighVariable(varargin)
        
        varargout = selectLowVariable(varargin)
        
        varargout = selectIndicatorVariable(varargin)
        
        varargout = setCandleWidth(varargin)
        
        varargout = setIndicatorColor(varargin)
        
        varargout = selectIndicatorLineStyle(varargin)
        
        varargout = selectIndicatorMarker(varargin)
        
        varargout = piePanel(varargin)
        
        varargout = setPieExplode(varargin)
        
        varargout = setPieTextExplode(varargin)
        
    end
    
    methods(Static=true)
        
        varargout = htmlColors(varargin)
        
    end
       
end
