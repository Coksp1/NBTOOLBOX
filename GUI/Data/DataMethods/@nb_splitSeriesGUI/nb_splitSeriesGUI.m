classdef nb_splitSeriesGUI < nb_methodGUI
% Description:
%
% Split one or more series at a given date.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_splitSeriesGUI(parent,data)
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

    properties (Access=protected,Hidden=true)
    
        dates       = [];
        postfix     = [];
        variables   = [];
        overlapping = [];
        
    end
    
    methods
        
        function gui = nb_splitSeriesGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = splitCallback(varargin)
                
    end
    
end
