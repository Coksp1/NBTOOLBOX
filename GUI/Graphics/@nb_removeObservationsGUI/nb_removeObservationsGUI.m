classdef nb_removeObservationsGUI < handle
% Description:
%
% This class makes a GUI for removing observations of the plotted variables
% using the nanVariables property of the nb_graph_ts class
%
% Constructor:
%
%   gui = nb_removeObservationsGUI(parent)
% 
%   Input:
%
%   - plotter : As a nb_graph_ts object
% 
%   Output:
% 
%   - gui     : A GUI
%
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the figure window of the GUI. As an 
        % nb_graphPanel object
        figureHandle  = [];
        
        % Handle to the graph object. As an nb_graph object.
        plotter       = [];
        
    end

    properties (Access = protected)
        
        panelHandle         = [];
        editBox1            = [];
        editBox2            = [];
        listBox             = [];
        typepopup           = [];
        textBox1            = [];
        textBox2            = [];
        varpopup            = [];
        
    end
    
    properties (Constant=true)
        
        text  = {'None','After','Before','Before and After','Between','Selection'}
        types = {'None','After','Before','BeforeAndAfter','Between','Ind'};
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_removeObservationsGUI(plotter)
        % Constructor
        
            gui.plotter = plotter;
            
            % Make the GUI
            gui.makeGUI();
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)

        varargout = changeVariable(varargin)
        
        varargout = changeType(varargin)
        
        varargout = selectDates(varargin)
        
        varargout = setValue(varargin)
        
        varargout = updatePanel(varargin)
        
        varargout = updateTypePanel(varargin)
        
    end
    
end
