classdef nb_bkfilterGUI < nb_methodGUI
% Description:
%
% A class for creating a dialog window to to band pass-filtering of 
% time-series.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_bkfilterGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - saveName   : As a string
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)

        edit1           = [];
        edit2           = [];
        edit3           = [];
        edit4           = [];
        list1           = [];
        oldBK1          = '8';
        oldBK2          = '32';
        rb1             = [];
        rb2             = [];
        rb3             = [];
        rb4             = [];
        
    end
    
    methods
        
        function gui = nb_bkfilterGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = gapSelectionCallback(varargin)
        
        varargout = trenSelectionCallback(varargin)
        
        varargout = bk1ChangedCallback(varargin)
        
        varargout = bk2ChangedCallback(varargin)
        
    end
    
end

