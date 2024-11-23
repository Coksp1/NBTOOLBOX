classdef nb_editTextArrow < handle
% Description:
%
% A class for editing an object of class nb_textArrow interactivly.
%
% Constructor:
%
%   gui = nb_editTextArrow(parent)
% 
%   Input:
%
%   - parent : An object of class nb_textArrow.
% 
%   Output:
% 
%   - gui    : An object of class nb_editTextArrow.
% 
% See also:
% nb_textArrow
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors
        defaultColors       = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_textBox object
        parent              = [];
        
    end
    
    properties(Access=protected)
        
        panelHandle1    = [];
        panelHandle2    = [];
        panelHandle3    = [];
        panelHandle4    = [];
        
        sideHandle      = [];
        
        colorpop1       = [];
        colorpop2       = [];
        colorpop3       = [];
        colorpop4       = [];
        colordef1       = [];
        colordef2       = [];
        colordef3       = [];
        colordef4       = [];
        
        colors          = {};
        valueColor      = [];
        valueColorTBC   = [];
        valueColorTEC   = [];
        valueColorTC    = [];
        
    end
    
    methods
        
        function gui = nb_editTextArrow(parent)
        % Constructor
        
            if isa(parent,'nb_textArrow')
                gui.parent = parent;
            else
                error([mfilename ':: The parent input must be of class nb_textArrow'])
            end
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = arrowPanel(varargin)
        
        varargout = textPanel(varargin)
        
        varargout = boxPanel(varargin)
        
        varargout = generalPanel(varargin)
        
        varargout = set(varargin)
        
        varargout = getColorsSelected(varargin)
        
    end
    
end
