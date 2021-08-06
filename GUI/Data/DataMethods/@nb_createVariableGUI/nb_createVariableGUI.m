classdef nb_createVariableGUI < nb_methodGUI
% Description:
%
% Open up the create variable dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_createVariableGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : Either 'variable' or 'type'.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    properties 
        % Either 'variable' or 'type'
        type = '';
    end   
        
    properties (Access=protected,Hidden=true)
        
        editbox1    = [];
        editbox2    = [];
        textboxHelp = [];
        panel1      = [];
        panel2      = [];
        help        = [];
        
    end
    
    methods
        
        function gui = nb_createVariableGUI(parent,data,type)
           
   
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
         
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = createVariableCallback(varargin)
        
    end
    
    methods(Static=true)
        
        varargout = funclist(varargin)
        
        varargout = helpOn(varargin)
        
      
    end
        
    
end
