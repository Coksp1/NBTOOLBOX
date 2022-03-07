classdef nb_editCurlyBrace < handle
% Description:
%
% A class for editing an object of class nb_curlyBrace interactivly.
%
% Constructor:
%
%   gui = nb_editCurlyBrace(parent)
% 
%   Input:
%
%   - parent : An object of class nb_curlyBrace.
% 
%   Output:
% 
%   - gui    : An object of class nb_editCurlyBrace
%
% See also:
% nb_arrow
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
        
        panelHandle1 = [];
        panelHandle2 = [];
        sideHandle   = [];
        xdata1       = [];
        xdata2       = [];
        ydata1       = [];
        ydata2       = [];
        
    end
    
    methods
        
        function gui = nb_editCurlyBrace(parent)
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
