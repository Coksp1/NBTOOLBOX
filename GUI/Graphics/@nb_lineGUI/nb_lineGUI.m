classdef nb_lineGUI < handle
% Description:
%
% This class makes a GUI for setting properties of different
% line object of a plot
%
% Constructor:
%
%   gui = nb_lineGUI(parent,type)
% 
%   Input:
%
%   - parent : As an nb_graphGUI object
%
%   - type   : Either 'horizontal', 'vertical' or 'line'.
% 
%   Output:
% 
%   - gui    : A GUI
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

    properties (Access = protected)
        
        panelHandle         = [];
        popupmenu1          = [];
        popupmenu2          = [];
        popupmenu3          = [];
        radiobutton1        = [];
        radiobutton2        = [];
        editbox1            = [];
        editbox2            = [];
        editbox3            = [];
        editbox4            = [];
        editbox5            = [];
        type                = '';
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_lineGUI(plotter,type)
        % Constructor
        
            gui.plotter = plotter;
            gui.type    = type;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addLineObject(varargin)
        
        varargout = changeLineObject(varargin)
        
        varargout = deleteLineObject(varargin)
        
        varargout = placeBetween(varargin)
        
        varargout = selectLineColor(varargin)
        
        varargout = setLineStyle(varargin)
        
        varargout = setLineValue(varargin)
        
        varargout = setLineWidth(varargin)
        
        varargout = setVerticalLineLimit(varargin)
        
        varargout = setVerticalLineManualYLimits(varargin)
        
        varargout = updateLinePanel(varargin)
        
    end
    
end
