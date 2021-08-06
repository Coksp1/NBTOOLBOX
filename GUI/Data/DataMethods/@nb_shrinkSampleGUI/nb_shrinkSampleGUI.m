classdef nb_shrinkSampleGUI < nb_methodGUI
% Description:
%
% Open up the shrink sample dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_shrinkSampleGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        figureHandle  = [];
        list1         = [];
        
    end
    
    methods
        
        function gui = nb_shrinkSampleGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
