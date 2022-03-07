classdef nb_reorderPackageGUI < handle
% Description:
%
% A class that makes it possible to reorder the graphs in an
% nb_graph_package object, which is opened in an 
% nb_graph_packageGUI window.
%
% Constructor:
%
%   gui = nb_reorderPackageGUI(parent,package)
% 
%   Input:
%
%   - parent  : As a nb_GUI object.
%
%   - plotter : As a nb_graph object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % As an nb_graph_package object
        package         = [];
        
        % As an nb_GUI object
        parent          = [];
        
    end
    
    properties(Access=protected)
       
        listbox         = [];
        editbox1        = [];
        editbox2        = [];
        
    end
    
    events
        
        packageChanged
        
    end
    
    methods
        
        function gui = nb_reorderPackageGUI(parent,package)
        % Constructor
        
            gui.parent  = parent;
            gui.package = package;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = changeSelectedGraph(varargin)
        
        varargout = moveDownCallback(varargin)
        
        varargout = moveFirstCallback(varargin)
        
        varargout = moveLastCallback(varargin)
        
        varargout = moveUpCallback(varargin)
        
    end
    
end

