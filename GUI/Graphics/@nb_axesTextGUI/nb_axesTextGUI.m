classdef nb_axesTextGUI < handle
% Description:
%
% This class makes a GUI for setting properties of the text of the
% axes, as title and axes labels.
%
% Constructor:
%
%   gui = nb_axesTextGUI(parent)
% 
%   Input:
%
%   - plotter : As an nb_graph_obj
%
%   - type    : Either 'title', 'xLabel', 'yLabel' or 'yLabelRight'.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        figureHandle        = [];
        plotter             = [];
        type                = '';
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_axesTextGUI(plotter,type)
        % Constructor
        
            gui.plotter = plotter;
            gui.type    = type;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        varargout = makeGUI(varargin)
        varargout = setFontSize(varargin)
        varargout = setFontWeight(varargin)
        varargout = setInterpreter(varargin)
        varargout = setText(varargin)
    end
    
end
