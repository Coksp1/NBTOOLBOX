classdef nb_variableToPlotXGUI < handle
% Description:
%
% This class makes a GUI for setting the variableToPlotX property 
% interacivly.
%
% Constructor:
%
%   gui = nb_variableToPlotXGUI(plotter)
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
        
        function gui = nb_variableToPlotXGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        varargout = selectVarXCallback(varargin)
        
    end
    
end

