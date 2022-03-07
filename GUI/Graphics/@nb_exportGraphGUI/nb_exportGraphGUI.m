classdef nb_exportGraphGUI < handle
% Description:
%
% A class for the export graphics from main GUI.
%
% Constructor:
%
%   gui = nb_exportGraphGUI(parent,graphGUI)
% 
%   Input:
%
%   - plotter  : An object of class nb_graph, nb_graph_adv or
%                nb_graph_subplot.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an 
%                nb_exportGraphGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the MATLAB figure.
        figureHandle    = [];
        
        % An object of class nb_graph_ts, nb_graph_cs or 
        % nb_graph_adv
        plotter         = [];
        
        
    end
    
    properties(Access=protected)
        
        edit1       = [];    
        pop1        = [];
        rb1         = [];
        rb2         = [];
        rb3         = [];
        rb4         = [];
        rb5         = [];
        cropBoxes   = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_exportGraphGUI(plotter)
        % Constructor 
        
            gui.plotter = plotter;
            makeGUI(gui)
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = browse(varargin)
        
        varargout = cancel(varargin)
        
        varargout = fileTypeCallback(varargin)
        
        varargout = saveToFile(varargin)

    end
    
end
