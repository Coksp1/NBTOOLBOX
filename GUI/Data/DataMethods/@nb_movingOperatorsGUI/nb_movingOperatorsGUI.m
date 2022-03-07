classdef nb_movingOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the moving operators (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_movingOperatorsGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : Type of operator as a string
% 
%   Output:
% 
%   - gui        : An object of class nb_movingOperatorsGUI.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'mstd','mavg'
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        edit2         = [];
        edit3         = [];
        figureHandle  = [];
        list1         = [];
        rball         = [];
        
    end
    
    methods
        
        function gui = nb_movingOperatorsGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
