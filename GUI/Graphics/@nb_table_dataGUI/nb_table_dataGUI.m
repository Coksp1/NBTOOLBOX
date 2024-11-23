classdef nb_table_dataGUI < nb_graphGUI
% Description:
%
% A class for creating data table interactivly.
%
% Superclasses:
%
% handle, nb_graphGUI
%
% Constructor:
%
%   gui = nb_table_dataGUI(parent,type,plotter)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - type     : Eiter 'normal' or 'advanced'
%
%   - plotter  : An nb_table_data or nb_graph_adv object. 
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_table_dataGUI object.
%
% Written by Kenneth Sæterhagen Paulsen 
        
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
         
    end
    
    properties(Access=protected)
        
        % Handle to the uicontextmenu object of the graph
        axesContextMenu     = [];   
        
    end
    
    methods
        
        function gui = nb_table_dataGUI(parent,type,plotter)
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
            set(gui.figureHandle,'name',[gui.parent.guiName ': Data Table: ']);
            
            % Enable the menu bars and plot the graph
            make_dataGUI(gui);
            
            % Check the loaded nb_graph_cs or nb_graph_adv object
            checkGraphObject(gui,plotter);
            
        end
        
    end
    
    
    methods(Access=protected,Hidden=true)
        
        varargout = make_dataGUI(varargin)
         
    end
    
end
