classdef nb_fanLegendGUI < handle
% Description:
%
% This class makes a GUI for setting fan legend properties interacivly.
%
% Constructor:
%
%   gui = nb_fanLegendGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph_ts or a nb_graph_data object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
% 
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_graph_ts object
        plotter             = [];
       
    end
    
    properties(Access=protected)
        
        popupmenu1   = [];
        radiobutton1 = [];
        editbox1     = [];
        editbox2     = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_fanLegendGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
             
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = set(varargin)
        
    end
    
end
