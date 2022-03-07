classdef nb_lastObservationGUI < nb_methodGUI
% Description:
%
% Get n last observations of a nb_ts or nb_data 
% object.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_lastObservation(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts  or nb_data.
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
        editbox     = [];        
    end
    
    methods
        
        function gui = nb_lastObservationGUI(parent,data)
           
            gui      = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = lastObservationCallback(varargin)
                
    end
    
end
