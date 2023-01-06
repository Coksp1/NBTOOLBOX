classdef nb_editColorBar < handle
% Description:
%
% A class for editing an object of class nb_colorbar interactivly.
%
% Constructor:
%
%   gui = nb_editColorBar(parent)
% 
%   Input:
%
%   - parent : An object of class nb_colorbar.
% 
%   Output:
% 
%   - gui    : An object of class nb_editColorBar.
% 
% See also:
% nb_colorbar
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
  
    end
    
    methods
        
        function gui = nb_editColorBar(parent)
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
        varargout = generalPanel(varargin)
        varargout = set(varargin)
        varargout = getColorsSelected(varargin)
        
    end
    
end
