classdef nb_fillNaNGUI < nb_methodGUI
% Description:
%
% Open up the fillNaN dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_fillNaNGUI(parent,data)
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

    properties(Access=protected,Hidden=true)
        
        components = struct;
        
    end
    
    methods
        
        function gui = nb_fillNaNGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
