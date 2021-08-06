classdef nb_table_cellGUI < nb_graphGUI
% Description:
%
% A class for creating cell data table interactivly.
%
% Superclasses:
%
% handle, nb_graphGUI
%
% Constructor:
%
%   gui = nb_table_cellGUI(parent,type,plotter)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - type     : Eiter 'normal' or 'advanced'
%
%   - plotter  : An nb_table_cell or nb_graph_adv object. 
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_table_cellGUI object.
%
% Written by Kenneth Sæterhagen Paulsen 
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
         
    end
    
    properties(Access=protected)
        
        % Handle to the uicontextmenu object of the graph
        axesContextMenu     = [];   
        
    end
    
    methods
        
        function gui = nb_table_cellGUI(parent,type,plotter)
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
            set(gui.figureHandle,'name',[gui.parent.guiName ': Cell Data Table: ']);
            
            % Enable the menu bars and plot the graph
            make_cellGUI(gui);
            
            % Check the loaded nb_graph_cs or nb_graph_adv object
            checkGraphObject(gui,plotter);
            
        end
        
    end
    
    
    methods(Access=protected,Hidden=true)
        
        varargout = make_cellGUI(varargin)
         
    end
    
end
