classdef nb_easterDummyGUI < nb_methodGUI
% Description:
%
% Add easter dummy variable to nb_ts object
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_easterDummyGUI(parent,data)
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
% Written by Kenneth S�terhagen Paulsen
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    properties
    end
    
    properties (Access=protected,Hidden=true)
        components = struct;
    end
    
    methods
        
        function gui = nb_easterDummyGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
                
    end
    
end
