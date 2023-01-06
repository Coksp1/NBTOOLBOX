classdef nb_addToCellGUI < nb_methodGUI
% Description:
%
% Add row or column to a nb_cell object
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_addToCellGUI(parent,data)
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'row' or 'column'.
        type       = '';
         
    end

    properties (Access=protected,Hidden=true)
    
        location       = [];
        
    end
    
    methods
        
        function gui = nb_addToCellGUI(parent,data,type)
           
            gui = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addCallback(varargin)
                
    end
    
end
