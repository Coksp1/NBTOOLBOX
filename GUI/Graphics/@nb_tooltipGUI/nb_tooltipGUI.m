classdef nb_tooltipGUI < handle
% Description:
%
% This class makes a GUI for setting the tooltip of a nb_graph_adv object
%
% Constructor:
%
%   gui = nb_tooltipGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Per Bjarne Bye   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph_adv object
        plotter             = [];
        
        editBox1            = [];
        editBox2            = [];
        popupmenu           = [];
        tooltipWrapping     = [];
        wrapInfo            = [];
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_tooltipGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = setTooltipCallback(varargin)
        
    end
    
end
