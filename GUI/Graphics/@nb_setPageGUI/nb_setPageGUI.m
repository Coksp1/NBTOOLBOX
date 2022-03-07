classdef nb_setPageGUI < handle
% Description:
%
% This class makes a GUI for setting the plotted page interacivly.
%
% Constructor:
%
%   gui = nb_setPageGUI(plotter)
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
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        figureHandle    = []; 
        
        plotter         = [];
        
    end
    
    properties (Access=protected,Hidden=true)
        
       popupmenu        = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_setPageGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = selectPageCallback(varargin)
        
    end
    
end

