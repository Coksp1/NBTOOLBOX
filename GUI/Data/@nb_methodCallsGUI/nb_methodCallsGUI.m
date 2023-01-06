classdef nb_methodCallsGUI < nb_methodGUI & nb_tableEditGUI
% Description:
%
% This is a class for making it possible to look and edit at the methods 
% that is called on the nb_dataSource object
%
% Constructor:
%
%   gui = nb_methodCallsGUI(parent,DB)
% 
%   Input:
%
%   - parent : A nb_GUI object
%
%   - data   : A nb_ts, nb_cs or nb_data object
% 
%   Output:
% 
%   - A GUI
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % Handle to the figure
        figureHandle        = [];
        
        % List box with sources to select
        list                = [];
        
        % List of sources of the data. As a cellstr.
        sources             = {};
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_methodCallsGUI(parent,data)
        
            % Constructor
            gui = gui@nb_methodGUI(parent,data);
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
         
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = addCallback(varargin)
        varargout = cellEdit(varargin)
        varargout = deleteCallback(varargin)
         
    end
    
end
