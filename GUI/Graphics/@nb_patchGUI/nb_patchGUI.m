classdef nb_patchGUI < handle
% Description:
%
% This class makes a GUI for setting properties of patch objects
%
% Constructor:
%
%   gui = nb_patchGUI(parent)
% 
%   Input:
%
%   - parent : As an nb_patchGUI object
% 
%   Output:
% 
%   - gui    : A GUI
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Default colors, when parent is empty.
        defaultColors   = nb_defaultColors();
        
        % As an nb_graph object
        plotter             = [];
        
    end

    properties (Access = protected)

        figureHandle        = [];
        panelHandle         = [];
        popupmenu1          = [];
        popupmenu2          = [];
        popupmenu3          = [];
        popupmenu4          = [];
        editbox1            = [];
        editbox2            = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_patchGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addPatchObject(varargin)
        
        varargout = changePatchObject(varargin)
        
        varargout = deletePatchObject(varargin)
        
        varargout = selectColor(varargin)
        
        varargout = setValue(varargin)
        
        varargout = updatePatchPanel(varargin)
        
    end
    
end
