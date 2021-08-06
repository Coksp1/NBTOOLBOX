classdef nb_editTextBox < handle
% Description:
%
% A class for editing an object of class nb_textBox interactivly.
%
% Constructor:
%
%   gui = nb_editTextBox(parent)
% 
%   Input:
%
%   - parent : An object of class nb_textBox.
% 
%   Output:
% 
%   - gui    : An object of class nb_editTextBox.
% 
% See also:
% nb_textBox
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors
        defaultColors       = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_textBox object
        parent              = [];
        
    end
    
    properties(Access=protected)
        
        panelHandle1 = [];
        panelHandle2 = [];
        panelHandle3 = [];
        panelHandle4 = [];
        
        sideHandle   = [];
        
        colorpop1    = [];
        colordef1    = [];
        colorpop2    = [];
        colordef2    = [];
        colorpop3    = [];
        colordef3    = [];
        
        colors          = {};
        valueColorTBC   = [];
        valueColorTEC   = [];
        valueColorTC    = [];
        
    end
    
    methods
        
        function gui = nb_editTextBox(parent)
        % Constructor
        
            gui.parent = parent;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = textPanel(varargin)
        
        varargout = boxPanel(varargin)
        
        varargout = generalPanel(varargin)
        
        varargout = set(varargin)
        
        varargout = getColorsSelected(varargin)
        
    end
    
end
