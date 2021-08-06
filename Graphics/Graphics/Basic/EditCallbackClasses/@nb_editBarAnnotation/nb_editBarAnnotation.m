classdef nb_editBarAnnotation < handle
% Description:
%
% A class for editing an object of class nb_barAnnotation
% interactivly.
%
% Constructor:
%
%   gui = nb_editBarAnnotation(parent)
% 
%   Input:
%
%   - parent : An object of class nb_barAnnotation.
% 
%   Output:
% 
%   - gui    : An object of class nb_editBarAnnotation.
% 
% See also:
% nb_barAnnotation
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors
        defaultColors       = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % As an nb_barAnnotation object
        parent              = [];
        
    end
    
    properties(Access=protected)
        
        panelHandle1 = [];
        panelHandle2 = [];
        
    end
    
    methods
        
        function gui = nb_editBarAnnotation(parent)
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
        
    end
    
end
