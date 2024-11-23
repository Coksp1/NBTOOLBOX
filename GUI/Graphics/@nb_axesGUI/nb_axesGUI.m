classdef nb_axesGUI < handle
% Description:
%
% This class makes a GUI for setting axes properties interacivly.
%
% Constructor:
%
%   gui = nb_axesGUI(plotter)
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
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors, when parent is empty.
        defaultColors       = nb_defaultColors();
        
        figureHandle        = [];
        buttonPanel         = [];
        buttonGroup         = [];
        editBox1            = [];
        editBox2            = [];
        editBox3            = [];
        editBox4            = [];
        editBox5            = [];
        editBox6            = [];
        panelHandle1        = [];
        panelHandle2        = [];
        panelHandle3        = [];
        panelHandle4        = [];
        panelHandle5        = [];
        colorMapPanel       = [];
        colorMapEdit        = [];
        plotter             = [];
        selectedCells       = [];
        table               = [];
        table2              = [];
        xTickStart          = [];
        
    end
    
    events
        
        % Notify that changes has been made to the graph object
        % stored as the property plotter
        changedGraph
        
    end
    
    methods
        
        function gui = nb_axesGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        varargout = changePanel(varargin)
        varargout = enableEditDates(varargin)
        varargout = enableEditXLim(varargin)
        varargout = enableEditYLim(varargin)
        varargout = generalPanel(varargin)
        varargout = locateColor(varargin)
        varargout = setAddSpace(varargin)
        varargout = setAxesDateInterpreter(varargin)
        varargout = setAxesFontSize(varargin)
        varargout = setAxesFontWeight(varargin)
        varargout = setAxesGrid(varargin)
        varargout = setAxesGridLineStyle(varargin)
        varargout = setAxesPosition(varargin)
        varargout = setAxesShading(varargin)
        varargout = setEndGraph(varargin)
        varargout = setStartGraph(varargin)
        varargout = setXAxisLabelAlignment(varargin)
        varargout = setXAxisLabelLocation(varargin)
        varargout = setXAxisScale(varargin)
        varargout = setXAxisSpacing(varargin)
        varargout = setXAxisTickLocation(varargin)
        varargout = setXAxisTickRotation(varargin)
        varargout = setXAxisTickStartDate(varargin)
        varargout = setXLim(varargin)
        varargout = setXTickFrequency(varargin)
        varargout = setYAxisDir(varargin)
        varargout = setYAxisScale(varargin)
        varargout = setYAxisSpacing(varargin)
        varargout = setYLim(varargin)
        varargout = xAxisPanel(varargin)
        varargout = yAxisPanel(varargin)
        varargout = radarPanel(varargin)
        varargout = cellEdit(varargin)
        varargout = setRadarNumberOfIsoLines(varargin)
        varargout = setRadarRotate(varargin)
        varargout = setRadarScale(varargin)
        varargout = piePanel(varargin)
        varargout = setPieType(varargin)
        varargout = setPieLabelsExtension(varargin)
        
    end
    
end
