classdef nb_subOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the sub operators (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_subOperatorsGUI(parent,data,type)
%
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
%
%   - type       : The type of sub operator, as a string.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'subSum','subAvg'.
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        figureHandle  = [];
        comp          = struct();
        
    end
    
    methods
        
        function gui = nb_subOperatorsGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = allCallback(varargin)
        
    end
    
end
