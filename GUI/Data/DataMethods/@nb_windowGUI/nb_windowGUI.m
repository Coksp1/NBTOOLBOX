classdef nb_windowGUI < nb_methodGUI
% Description:
%
% Open up the window of dataset (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_windowGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI.
%
%   - data   : The data that you want to use the unit root method on.
%
%   Output:
%   
%   - gui    : The handle of the gui object, as a nb_windowGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        popupmenu1      = [];
        popupmenu2      = [];
        
    end
    
    methods
        
        function gui = nb_windowGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = windowCallback(varargin)
        
    end
    
end
