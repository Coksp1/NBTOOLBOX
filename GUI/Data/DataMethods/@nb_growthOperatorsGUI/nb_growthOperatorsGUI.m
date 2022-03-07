classdef nb_growthOperatorsGUI < nb_methodGUI
% Description:
%
% Open up the growth operators (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_growthOperatorsGUI(parent,data,type)
%
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : Type of operator to do, as a string.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'growth','egrowth','pcn', 'epcn', 'sgrowth'
        type            = '';
        
    end
    
    properties(Access=protected,Hidden=true)
        
        figureHandle  = [];
        comp          = struct();
       
    end
    
    methods
        
        function gui = nb_growthOperatorsGUI(parent,data,type)
           
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
