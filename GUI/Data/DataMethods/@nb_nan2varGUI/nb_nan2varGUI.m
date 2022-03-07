classdef nb_nan2varGUI < nb_methodGUI
% Description:
%
% Open up the nan2var (assign nan values) (time-series) dialog 
% window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_nan2varGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - gui        : An object of class nb_appendDataGUI.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        pop1          = [];
        figureHandle  = [];
        list1         = [];
        
    end
    
    methods
        
        function gui = nb_nan2varGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
