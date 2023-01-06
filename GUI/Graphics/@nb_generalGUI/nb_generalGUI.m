classdef nb_generalGUI < handle
% Description:
%
% This class makes a GUI for setting general properties interacivly.
%
% Constructor:
%
%   gui = nb_generalGUI(plotter)
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
        
        panelHandle1    = [];
        panelHandle2    = [];
        panelHandle3    = [];
        panelHandle4    = [];
        panelHandle5    = [];
        
        handle1         = [];
        handle2         = [];
        handle3         = [];
        handle4         = [];
        handle5         = [];
        handlec         = [];
        
        selected        = {};
        selectedCells   = [];
        table           = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_generalGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
          
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = plotPanel(varargin)
        
        varargout = missingPanel(varargin)
        
        varargout = baselinePanel(varargin)
        
        varargout = textPanel(varargin)
        
        varargout = lookUpMatrixPanel(varargin)
        
        varargout = set(varargin)
        
        varargout = cellEdit(varargin)
        
        varargout = setBaslineOnOff(varargin)

        varargout = addRow(varargin)

        varargout = deleteRow(varargin)
        
    end
    
end
