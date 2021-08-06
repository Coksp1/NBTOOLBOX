classdef nb_selectPlotTypeGUI < handle
% Description:
%
% Select the type of plot to make.
%
% Constructor:
%
%   gui = nb_selectPlotTypeGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth S�terhagen Paulsen
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    properties
        
        figureHandle    = [];
        
        plotter         = [];
        
    end
    
    events
        
        graphStyleChanged
        
    end
    
    methods
        
        function gui = nb_selectPlotTypeGUI(plotter)
            
            gui.plotter = plotter;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = setPlotType(varargin)
        
    end
    
end

