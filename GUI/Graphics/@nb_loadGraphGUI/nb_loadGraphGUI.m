classdef nb_loadGraphGUI < handle
% Description:
%
% A class for loading a graph object from the graphs property of 
% the main GUI
%
% Constructor:
%
%   gui = nb_loadGraphGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an  
%              nb_loadGraphGUI object.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the figure of the GUI
        fig         = [];
        
        % Handle to the list box to select the graph objects from
        listBox     = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
        % The loaded graph object as an nb_graph or nb_graph_adv
        % object
        plotter     = [];
        
        % Name of the loaded graph object
        plotterName = '';
        
    end
    
    events
        
        loadObjectFinished
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
       
        function gui = nb_loadGraphGUI(parent)
        % Constructor

            % Assign properties
            gui.parent = parent;
            
            % Make GUI
            makeGUI(gui);

        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = selectGraph(varargin)
        
    end
    
end
