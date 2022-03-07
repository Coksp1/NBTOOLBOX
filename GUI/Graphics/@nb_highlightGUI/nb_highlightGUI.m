classdef nb_highlightGUI < handle
% Description:
%
% This class makes a GUI for setting properties of the highlight
% of a plot
%
% Constructor:
%
%   gui = nb_highlightGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : A GUI
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        editbox1            = [];
        editbox2            = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_highlightGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addHighlightObject(varargin)
        
        varargout = changeHighlightObject(varargin)
        
        varargout = deleteHighlightObject(varargin)
        
        varargout = selectColor(varargin)
        
        varargout = setValue(varargin)
        
        varargout = updatePanel(varargin)
        
    end
    
end
