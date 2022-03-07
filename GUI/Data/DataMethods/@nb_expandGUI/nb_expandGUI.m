classdef nb_expandGUI < nb_methodGUI
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
%   gui = nb_expand(parent,data)
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
        startBox        = [];
        endBox          = [];
        typePop         = [];
        typePopOptions  = {};
    end
    
    methods
        
        function gui = nb_expandGUI(parent,data)
           
            gui      = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = expandCallback(varargin)
                
    end
    
end
