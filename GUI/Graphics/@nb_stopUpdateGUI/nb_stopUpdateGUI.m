classdef nb_stopUpdateGUI < handle
% Description:
%
% This class makes a GUI for setting the stopUpdate property of the 
% nb_graph object.
%
% Constructor:
%
%   gui = nb_stopUpdateGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph object
        plotter             = [];
        
        % A struct with the GUI uicontrol objects.
        comp                = [];
        
    end
    
    events  
        changedGraph
    end
    
    methods
        
        function gui = nb_stopUpdateGUI(plotter)
            gui.plotter = plotter;
            gui.makeGUI();
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        varargout = makeGUI(varargin)
        varargout = setCallback(varargin)
    end
    
end
