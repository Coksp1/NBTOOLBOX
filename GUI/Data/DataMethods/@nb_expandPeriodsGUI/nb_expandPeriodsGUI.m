classdef nb_expandPeriodsGUI < nb_methodGUI
% Description:
%
% Expand window of a nb_ts or nb_data object
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_expandPeriods(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
    end
    
    properties (Access=protected,Hidden=true)
        numOfPeriodsBox = [];
        typePop         = [];
        typePopOptions  = {};
    end
    
    methods
        
        function gui = nb_expandPeriodsGUI(parent,data)
           
            gui      = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = expandPeriodsCallback(varargin)
                
    end
    
end
