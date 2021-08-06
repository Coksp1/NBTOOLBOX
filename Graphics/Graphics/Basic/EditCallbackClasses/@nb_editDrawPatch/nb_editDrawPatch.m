classdef nb_editDrawPatch < handle
% Description:
%
% A class for editing an object of class nb_drawPatch interactivly.
%
% Constructor:
%
%   gui = nb_editDrawPatch(parent)
% 
%   Input:
%
%   - parent : An object of class nb_drawPatch.
% 
%   Output:
% 
%   - gui    : An object of class nb_editDrawPatch
%
% See also:
% nb_drawPatch
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
        
    end
    
    methods
        
        function gui = nb_editDrawPatch(parent)
        % Constructor
        
            gui.parent = parent;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = lookPanel(varargin)
        
        varargout = generalPanel(varargin)
        
        varargout = set(varargin)
        
    end
    
end
