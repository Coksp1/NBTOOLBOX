classdef nb_roundOffGUI < handle
% Description:
%
% This class makes a GUI for setting roundOff property of a 
% nb_graph_adv object
%
% Constructor:
%
%   gui = nb_roundOffGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph_adv object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth S�terhagen Paulsen   
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph_adv object
        plotter             = [];
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_roundOffGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = setProperty(varargin)
        
    end
    
end
