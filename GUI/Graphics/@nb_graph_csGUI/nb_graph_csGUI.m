classdef nb_graph_csGUI < nb_graphGUI
% Description:
%
% A class for creating corss-sectional data plot interactivly.
%
% Superclasses:
%
% handle, nb_graphGUI
%
% Constructor:
%
%   gui = nb_graph_csGUI(parent,varargin)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - type     : Eiter 'normal' or 'advanced'
%
%   - plotter  : An nb_graph_cs or nb_graph_adv object. 
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_graph_csGUI object.
%
% Written by Kenneth Sæterhagen Paulsen 
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods
        
        function gui = nb_graph_csGUI(parent,type,plotter,template)
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
            set(gui.figureHandle,'name',[gui.parent.guiName ': Cross-Sectional Data Graphics: ']);
            
            % Enable the menu bars and plot the graph
            make_csGUI(gui);
            
            % Check the loaded nb_graph_cs or nb_graph_adv object
            checkGraphObject(gui,plotter);
            
        end
        
    end
    
    
    methods(Hidden=true)
        varargout = make_csGUI(varargin)
        varargout = checkGraphObject(varargin) 
    end
    
end
