classdef nb_editDrawLine < handle
% Description:
%
% A class for editing an object of class nb_editDrawLine interactivly.
%
% Constructor:
%
%   gui = nb_editDrawLine(parent)
% 
%   Input:
%
%   - parent : An object of class nb_drawLine.
% 
%   Output:
% 
%   - gui    : An object of class nb_editDrawLine
%
% See also:
% nb_drawLine
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors
        defaultColors       = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_drawPatch object
        parent              = [];
        
    end
    
    properties(Access=protected,Hidden=true)
        
        panelHandle1    = [];
        panelHandle2    = [];
        panelHandle3    = [];
        sideHandle      = [];
        colorpop1       = [];
        colordef1       = [];
        colors          = {};
        valueColor      = [];
        selectedCells   = [];
        table           = [];
         
    end
    
    methods
        
        function gui = nb_editDrawLine(parent)
        % Constructor
        
            gui.parent = parent;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = arrowPanel(varargin)
        
        varargout = generalPanel(varargin)
        
        varargout = set(varargin)
        
    end
    
end
