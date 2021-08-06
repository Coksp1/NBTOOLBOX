classdef nb_mathOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the mathematical operators dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_mathOperatorsGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : The math operator, as a string
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'log' | 'exp'
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        edit2         = [];
        figureHandle  = [];
        list1         = [];
        rball         = [];
        
    end
    
    methods
        
        function gui = nb_mathOperatorsGUI(parent,data,type)
           
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
