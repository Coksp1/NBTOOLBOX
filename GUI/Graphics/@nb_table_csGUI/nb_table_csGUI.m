classdef nb_table_csGUI < nb_graphGUI
% Description:
%
% A class for creating corss-sectional data table interactivly.
%
% Superclasses:
%
% handle, nb_graphGUI
%
% Constructor:
%
%   gui = nb_table_csGUI(parent,type,plotter)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - type     : Eiter 'normal' or 'advanced'
%
%   - plotter  : An nb_table_cs or nb_graph_adv object. 
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_table_csGUI object.
%
% Written by Kenneth Sæterhagen Paulsen 
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
         
    end
    
    properties(Access=protected)
        
        % Handle to the uicontextmenu object of the graph
        axesContextMenu     = [];   
        
    end
    
    methods
        
        function gui = nb_table_csGUI(parent,type,plotter)
        % Constructor    
            
            % Call the superclass constructor
            gui = gui@nb_graphGUI(parent,type,0,true);
            if isa(plotter,'nb_graph_adv')
                gui.plotter    = plotter.plotter;
                gui.plotterAdv = plotter;
            else
                gui.plotter = plotter;
            end
            
            % Change the figure name
            set(gui.figureHandle,'name',[gui.parent.guiName ': Cross-Sectional Data Table: ']);
            
            % Enable the menu bars and plot the graph
            make_csGUI(gui);
            
            % Check the loaded nb_graph_cs or nb_graph_adv object
            checkGraphObject(gui,plotter);
            
        end
        
    end
    
    
    methods(Access=protected,Hidden=true)
        
        varargout = make_csGUI(varargin)
         
    end
    
end
