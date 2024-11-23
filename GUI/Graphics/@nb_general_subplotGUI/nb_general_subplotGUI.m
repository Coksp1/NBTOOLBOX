classdef nb_general_subplotGUI < handle
% Description:
%
% This class makes a GUI for editing general properties of a  
% nb_graph_subplot object interacivly.
%
% Superclass:
%
% handle
%
% Constructor:
%
%   gui = nb_general_subplotGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph_subplot object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_graph_subplot object
        plotter             = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_general_subplotGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
          
        varargout = makeGUI(varargin)
        
        varargout = set(varargin)
        
    end
    
end

