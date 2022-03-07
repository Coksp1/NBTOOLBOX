classdef nb_editRegressLine < handle
% Description:
%
% A class for editing an object of class nb_regressLine interactivly.
%
% Constructor:
%
%   gui = nb_editRegressLine(parent)
% 
%   Input:
%
%   - parent : An object of class nb_regressLine.
% 
%   Output:
% 
%   - gui    : An object of class nb_editRegressLine
%
% See also:
% nb_regressLine
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        
        index           = 1;
        string          = [];
        positionX       = [];
        positionY       = [];
        
    end
    
    methods
        
        function gui = nb_editRegressLine(parent)
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
