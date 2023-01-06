classdef nb_editPlotLabels < handle
% Description:
%
% A class for editing an object of class nb_plotLabels
% interactivly.
%
% Constructor:
%
%   gui = nb_editPlotLabels(parent,class,index)
% 
%   Input:
%
%   - parent : An object of class nb_barAnnotation.
% 
%   Output:
% 
%   - gui    : An object of class nb_editPlotLabels.
% 
% See also:
% nb_barAnnotation
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Class for the underlying object to add labels to. Some options
        % may be affected by this.
        class               = '';
        
        % Default colors
        defaultColors       = nb_defaultColors();
        
        % A handle to the GUI window
        figureHandle        = [];
       
        % The index of the label that is beeing edited.
        index               = [];
        
        % As an nb_barAnnotation object
        parent              = [];
        
        % The level of editing. Either 'all', 'row', 'column' or 'cell'
        type                = 'all';
        
    end
    
    properties(Access=protected)
        
        format       = struct;
        panelHandle1 = [];
        panelHandle2 = [];
        panelHandle3 = [];
        panelHandle4 = [];
        colorHandles = struct;
        
    end
    
    events
       
        finished
        
    end
    
    methods
        
        function gui = nb_editPlotLabels(parent,class,index,type)
        % Constructor
        
            gui.parent = parent;
            gui.class  = class;
            gui.index  = index;
            gui.type   = type;
            gui.format = getFormat(gui);
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        
        varargout = makeGUI(varargin)
        
        varargout = changePanel(varargin)
        
        varargout = textPanel(varargin)
        
        varargout = generalPanel(varargin)
        
        varargout = set(varargin)
        
    end
    
end
