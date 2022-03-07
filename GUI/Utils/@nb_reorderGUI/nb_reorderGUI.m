classdef nb_reorderGUI < handle
% Description:
%
% A class for reordering a cellstr.
%
% Constructor:
%
%   gui = nb_reorderGUI(c)
% 
%   Input:
%
%   - c : A cellstr
% 
%   Output:
% 
%   - gui : An object of class nb_reorderGUI
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % As a cellstr
        cstr            = [];
        
        % Name of figure, as a string.
        name            = '';        
        
    end
    
    properties(Access=protected)
       
        listbox         = [];
        editbox1        = [];
        editbox2        = [];
        
    end
    
    events
        
        reorderingFinished
        
    end
    
    methods
        
        function gui = nb_reorderGUI(c,name)
        % Constructor
        
            gui.cstr  = c;
            gui.name  = name;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = moveDownCallback(varargin)
        
        varargout = moveFirstCallback(varargin)
        
        varargout = moveLastCallback(varargin)
        
        varargout = moveUpCallback(varargin)
        
    end
    
end

