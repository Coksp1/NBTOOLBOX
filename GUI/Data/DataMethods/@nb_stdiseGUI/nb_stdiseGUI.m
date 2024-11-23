classdef nb_stdiseGUI < nb_methodGUI
% Description:
%
% Open up the standardise dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_stdiseGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        figureHandle  = [];
        list1         = [];
        rb1           = [];
        rball         = [];
        
    end
    
    methods
        
        function gui = nb_stdiseGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
