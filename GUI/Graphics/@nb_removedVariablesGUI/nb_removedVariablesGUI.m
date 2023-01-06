classdef nb_removedVariablesGUI < handle
% Description:
%
% This class makes a GUI for setting removed property of a 
% nb_graph_adv object
%
% Constructor:
%
%   gui = nb_removedVariablesGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph_adv object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph_adv object
        plotter             = [];
        
        selList             = [];
        varList             = [];
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_removedVariablesGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = select(varargin)
        
        varargout = deSelect(varargin)
        
    end
    
end
