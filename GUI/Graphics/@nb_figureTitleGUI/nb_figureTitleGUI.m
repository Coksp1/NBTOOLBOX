classdef nb_figureTitleGUI < handle
% Description:
%
% This class makes a GUI for setting figure title of a nb_graph_adv object
%
% Constructor:
%
%   gui = nb_figureTitleGUI(plotter)
% 
%   Input:
%
%   - plotter : As a nb_graph object.
%
%   - type    : n x 1 char. Either "excel" or "normal". 
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % MATLAB figure handle
        figureHandle        = [];
        
        % A nb_graph_adv object
        plotter             = [];
        
        % 'excel' or 'normal'
        type                = 'normal';
        
        editBox1            = [];
        editBox2            = [];
        popupmenu           = [];
        figureTitleWrapping = [];
        wrapInfo            = [];
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_figureTitleGUI(plotter,type)
        % Constructor
            
            if nargin < 2
                type = 'normal';
            end
            gui.type    = type;
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = setFigureTitleCallback(varargin)
        
    end
    
end
