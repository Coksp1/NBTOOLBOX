classdef nb_roundGUI < nb_methodGUI
% Description:
%
% Open up the rounding dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_roundGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        edit2         = [];
        edit3         = [];
        edit4         = [];
        figureHandle  = [];
        list1         = [];
        rball         = [];
        
    end
    
    methods
        
        function gui = nb_roundGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = allCallback(varargin)
        
    end
    
end
