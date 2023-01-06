classdef nb_timingOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the timing operators (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_timingOperatorsGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : The type of timing operator, as a string.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'lag','lead'
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        edit2         = [];
        figureHandle  = [];
        list1         = [];
        oldPeriod     = '1';
        
    end
    
    methods
        
        function gui = nb_timingOperatorsGUI(parent,data,type)
           
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
