classdef nb_legendGUI < handle
% Description:
%
% This class makes a GUI for setting legend properties interacivly.
%
% Constructor:
%
%   gui = nb_legendGUI(plotter)
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
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors, when parent is empty.
        defaultColors   = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_graph object
        plotter             = [];
        
    end
    
    properties(Access=protected)
        
        panelHandle1 = [];
        panelHandle2 = [];
        panelHandle3 = [];
        panelHandle4 = [];
        table        = [];
        
        editbox1     = [];
        editbox2     = [];
        editbox3     = [];
        popupmenu1   = [];
        popupmenu2   = [];
        popupmenu3   = [];
        popupmenu4   = [];
        popupmenu5   = [];
        popupmenu6   = [];
        popupmenu7   = [];
        popupmenu8   = [];
        popupmenu9   = [];
        popupmenu10  = [];
        radiobutton1 = [];
        radiobutton2 = [];
        
    end
    
    events
        changedGraph
    end
    
    methods
        
        function gui = nb_legendGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true) 
        varargout = makeGUI(varargin)
        varargout = changePanel(varargin)
        varargout = generalPanel(varargin)
        varargout = textPanel(varargin)
        varargout = fakeLegendPanel(varargin)
        varargout = cellEdit(varargin)
        varargout = addFakeLegend(varargin)
        varargout = addShadingColor(varargin)
        varargout = changeFakeLegend(varargin)
        varargout = changeLocationOption(varargin)
        varargout = deleteFakeLegend(varargin)
        varargout = editColumnWidth(varargin)
        varargout = editFontSize(varargin)
        varargout = editSpace(varargin)
        varargout = selectFakeLegendColor(varargin)
        varargout = selectFakeLegendEdgeColor(varargin)
        varargout = setBoxOption(varargin)
        varargout = setColumns(varargin)
        varargout = setFakeLegendLineWidth(varargin)
        varargout = setFakeLegendProperty(varargin)
        varargout = setInterpreter(varargin)
        varargout = setNoLegend(varargin)
        varargout = setLocation(varargin)
        varargout = setPosition1(varargin)
        varargout = setPosition2(varargin)
        varargout = setReorder(varargin)
        varargout = updateFakeLegendPanel(varargin)
    end
    
end
