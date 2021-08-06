classdef nb_deleteVariablesGUI < nb_methodGUI
% Description:
%
% Open up the delete variables dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_deleteVariablesGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : As a string. Must be 'variables' or 'types'.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        % Must be 'variables' or 'types'.
        type = '';
    
    end


    properties (Access=protected,Hidden=true)
        
        figureHandle    = [];
        listbox         = [];
        
    end
    
    methods
        
        function gui = nb_deleteVariablesGUI(parent,data,type)
           
            gui = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = deleteCallback(varargin)
        
    end
    
end
