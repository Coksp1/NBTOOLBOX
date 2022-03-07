classdef nb_generalTableGUI < handle
% Description:
%
% A GUI for setting general properties of a table
%
% Constructor:
%
%   gui = nb_generalTableGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_table_data_source object.
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
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Handle to the graph object. As an nb_table_data_source object.
        plotter       = [];
        
    end
    
    properties(Access=protected)
        
        editBox1        = [];
        editBox2        = [];
        
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
        
        function gui = nb_generalTableGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
          
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = textPanel(varargin)
        
        varargout = lookUpMatrixPanel(varargin)
        
        varargout = set(varargin)
        
        varargout = cellEdit(varargin)
        
        varargout = addRow(varargin)

        varargout = deleteRow(varargin)
        
    end
    
end
