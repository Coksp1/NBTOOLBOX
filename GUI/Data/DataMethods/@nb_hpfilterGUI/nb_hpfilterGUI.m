classdef nb_hpfilterGUI < nb_methodGUI
% Description:
%
% A class for creating a dialog window to to hp-filtering of time-
% series.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_hpfilterGUI(parent,data)
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
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)

        edit1           = [];
        edit2           = [];
        edit3           = [];
        list1           = [];
        oldLambda       = '1600';
        rb1             = [];
        rb2             = [];
        rb3             = [];
        rb4             = [];
        
    end
    
    methods
        
        function gui = nb_hpfilterGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = gapSelectionCallback(varargin)
        
        varargout = trenSelectionCallback(varargin)
        
        varargout = lambdaChangedCallback(varargin)
        
    end
    
end

