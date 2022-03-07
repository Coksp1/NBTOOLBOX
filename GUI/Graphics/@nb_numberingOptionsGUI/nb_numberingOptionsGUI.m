classdef nb_numberingOptionsGUI < handle
% Description:
%
% This class makes a GUI for setting the numbering properties of a 
% nb_graph_adv object
%
% Constructor:
%
%   gui = nb_numberingOptionsGUI(plotter)
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
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph_adv object
        plotter             = [];
        
    end
    
    properties (Dependent=true)
        
        parent
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_numberingOptionsGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
        function value = get.parent(gui)
            if isa(gui.plotter,'nb_graph_adv')
                value = gui.plotter.plotter.parent;
            else
                value = [];
            end
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = setProperties(varargin)
        
    end
    
end
