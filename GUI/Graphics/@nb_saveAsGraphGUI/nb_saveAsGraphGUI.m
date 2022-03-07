classdef nb_saveAsGraphGUI < handle
% Description:
%
% Saves a graph object stored as an nb_graph_obj object to the main    
% program. Opens up a dialog box to give it a save name. Will trigger an 
% saveNameSelected event.
%
% Constructor:
%
%   gui = nb_saveAsGraphGUI(parent,plotter)
% 
%   Input:
%
%   - parent   : As an nb_GUI object.
% 
%   - plotter  : Either an nb_graph, nb_graph_subplot or 
%                nb_graph_adv object.
% 
%   Output:
% 
%   - Graph stored in the main program. And a saveNameSelected
%     event triggered.
% 
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % As an nb_GUI object
        parent      = [];
        
        % As a nb_graph_obj or nb_graph_adv object
        plotter     = [];
        
        % Selected save name
        saveName    = '';
        
    end
    
    properties (Access=protected,Hidden=true)
        
        editBox     = [];
        
    end
    
    events
       
        saveNameSelected
        
    end
    
    methods 
        
        function gui = nb_saveAsGraphGUI(parent,plotter)
            
            gui.parent  = parent;
            gui.plotter = plotter;
            makeGUI(gui);
            
        end
        
    end
    
    methods (Access=protected,Hidden=true)
        
       varargout = makeGUI(varargin) 
       
       varargout = saveRoutine(varargin) 
        
    end

end
