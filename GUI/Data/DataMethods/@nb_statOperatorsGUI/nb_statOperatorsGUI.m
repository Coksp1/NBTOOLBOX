classdef nb_statOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the statistics dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_statOperatorsGUI(parent,data,type)
%
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
%
%   - type       : The type of stat operator, as a string.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'var','std','mean','mode','median','min','max'
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        % A struct to store uicontrol components
        comp            = struct();
        
    end
    
    methods
        
        function gui = nb_statOperatorsGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        varargout = allCallback(varargin)
        varargout = dimCallback(varargin)
        varargout = calculateCallback(varargin)
        
    end
    
end
