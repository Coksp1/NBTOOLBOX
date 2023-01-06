classdef nb_footerGUI < handle
% Description:
%
% This class makes a GUI for setting footer of a nb_graph_adv object
%
% Constructor:
%
%   gui = nb_footerGUI(plotter)
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
        
        % A nb_graph_adv object
        plotter             = [];
        
        % 'excel' or 'normal'
        type                = 'normal';
        
        editBox1            = [];
        editBox2            = [];
        popupmenu           = [];
        footerWrapping      = [];
        wrapInfo            = [];
        
    end
    
    events 
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_footerGUI(plotter,type)
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
        
        varargout = setFooterCallback(varargin)
        
    end
    
end
