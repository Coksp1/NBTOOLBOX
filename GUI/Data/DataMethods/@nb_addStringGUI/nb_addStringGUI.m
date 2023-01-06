classdef nb_addStringGUI < nb_methodGUI
% Description:
%
% Add prefix or postfix to the variables of an nb_ts or nb_cs 
% object.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_addStringGUI(parent,data,type)
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'postfix' or 'prefix'.
        type        = '';
        
    end
    
    properties (Access=protected,Hidden=true)
    
        editbox     = [];
        list1       = [];
        
    end
    
    methods
        
        function gui = nb_addStringGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addStringCallback(varargin)
                
    end
    
end
