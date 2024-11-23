classdef nb_graph_tsGUI < nb_graphGUI
% Description:
%
% A class for creating time-series plot interactivly.
%
% Superclasses:
%
% handle, nb_graphGUI
%
% Constructor:
%
%   gui = nb_graph_tsGUI(parent,varargin)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - type     : Eiter 'normal' or 'advanced'
%
%   - plotter  : An nb_graph_ts or nb_graph_adv object.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_graph_tsGUI object.
%
% Written by Kenneth Sæterhagen Paulsen 
        
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    methods
        
        function gui = nb_graph_tsGUI(parent,type,plotter,template)
        % Constructor    
            
            if nargin < 4
                template = '';
            end
            if isempty(template)
                if strcmpi(type,'normal')
                    template = parent.settings.defaultNormalTemplate;
                else
                    template = parent.settings.defaultAdvancedTemplate;
                end
            end
            
            % Call the superclass constructor
            gui          = gui@nb_graphGUI(parent,type);
            gui.template = template;
            if isa(plotter,'nb_graph_adv')
                gui.plotter    = plotter.plotter(1);
                gui.plotterAdv = plotter;
            else
                gui.plotter = plotter;
            end
            
            % Change the figure name
            if isa(gui.parent,'nb_GUI')
                extra = [gui.parent.guiName ': ']; 
            else
                extra = '';
            end
            set(gui.figureHandle,'name',[extra 'Time-Series Graphics: ']);
            
            % Enable the menu bars and plot the graph
            make_tsGUI(gui);
            
            % Check the loaded nb_graph_t or nb_graph_adv object
            checkGraphObject(gui,plotter);
            
        end
        
    end
    
    
    methods(Hidden=true)
        varargout = make_tsGUI(varargin)
        varargout = checkGraphObject(varargin)
    end
    
end
