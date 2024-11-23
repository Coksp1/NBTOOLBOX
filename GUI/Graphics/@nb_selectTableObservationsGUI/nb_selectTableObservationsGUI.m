classdef nb_selectTableObservationsGUI < handle
% Description:
%
% Set the observation, types, variables of the table.
%
% Constructor:
%
%   gui = nb_selectTableObservationsGUI(plotter,type)
% 
%   Input:
%
%   - plotter : An object of class nb_table_data_source
% 
%   - type    : 'variables', 'types', 'observations' or 'dates'.
%
%   Output:
% 
%   - gui     : The handle to the object.
% 
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        figureHandle    = []; 
        
        % An object of class nb_table_data_source
        plotter         = [];
        
        % 'variables', 'types', 'observations' or 'dates'
        type            = '';
        
    end
    
    properties (Access=protected,Hidden=true)
        
       popupmenu        = [];
        
    end
    
    events
        
        changedGraph
        
    end
    
    methods
        
        function gui = nb_selectTableObservationsGUI(plotter,type)
        % Constructor
        
            gui.plotter = plotter;
            gui.type    = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
    end
    
end

