classdef nb_createDummyGUI < nb_methodGUI
% Description:
%
% A class for making a create dummy dialog.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_createDummyGUI(parent,data)
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

        edit1            = [];
        edit2            = [];
        edit3            = [];
        figureHandle     = [];
        pop1             = [];
        pop2             = [];
        pop3             = [];
        selectedCells    = [];
        table            = [];
        timeDummyPanel   = [];
        varDummyPanel    = [];
        seasonalDummyPanel = []
        
    end
    
    methods
        
        function gui = nb_createDummyGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = addRow(varargin)
        
        varargout = deleteRow(varargin)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = typeSelectionCallback(varargin)
        
    end
    
end

