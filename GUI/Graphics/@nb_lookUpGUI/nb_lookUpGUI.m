classdef nb_lookUpGUI < handle
% Description:
%
% This class for making the user edit the look up matrix of a graph
%
% Constructor:
%
%   gui = nb_lookUpGUI(parent,plotter)
% 
%   Input:
%
%   - plotter : A nb_graph object
% 
%   Output:
% 
%   - gui     : A GUI
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % Handle to the figure
        figureHandle        = [];
        
        % The graph as a nb_graph object
        plotter             = [];
        
        % The selected cells of the table
        selectedCells       = [];
        
        % Handle to the table of the GUI window
        table               = [];
        
    end
    
    properties (Dependent)
        keys
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_lookUpGUI(plotter)
        
            % Constructor
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
        function keys = get.keys(gui)
           tableData = get(gui.table, 'Data');
           keys = tableData(:, 1);
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addKeys(varargin)
        
        varargout = addRow(varargin)
        
        varargout = addAllVariables(varargin)
        
        varargout = addAllLegends(varargin)
        
        varargout = deleteRow(varargin)
        
        varargout = cellEdit(varargin)
        
        varargout = getSelectedCells(varargin)
         
    end
    
end
