classdef nb_stripGUI < nb_methodGUI
% Description:
%
% Strip observations GUI
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_stripGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : The type of strip operator, as a string.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'strip' or 'stripButLast'.
        type        = '';
        
    end
    
    properties (Access=protected,Hidden=true)
    
        editbox1    = [];
        editbox2    = [];
        list1       = [];
        
    end
    
    methods
        
        function gui = nb_stripGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = stripCallback(varargin)
                
    end
    
end
