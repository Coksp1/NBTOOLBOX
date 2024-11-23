classdef nb_detrendGUI < nb_methodGUI
% Description:
%
% A class for creating a dialog window to detrend time-series.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_detrendGUI(parent,data)
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
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)

        pop1            = [];
        edit2           = [];
        edit3           = [];
        list1           = [];
        rb1             = [];
        rb2             = [];
        rb3             = [];
        rb4             = [];
        
    end
    
    methods
        
        function gui = nb_detrendGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = gapSelectionCallback(varargin)
        
        varargout = trenSelectionCallback(varargin)
        
    end
    
end

