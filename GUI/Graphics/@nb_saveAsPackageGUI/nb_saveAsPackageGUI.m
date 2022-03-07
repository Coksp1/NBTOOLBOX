classdef nb_saveAsPackageGUI < handle
% Description:
%
% Saves a graph package object stored as an nb_graph_package object 
% to the main program. Opens up a dialog box to give it a save
% name. Will trigger an saveNameSelected event.
%
% Constructor:
%
%   gui = nb_saveAsPackageGUI(parent,package)
% 
%   Input:
%
%   - parent   : As an nb_GUI object.
% 
%   - package  : As an nb_graph_package object.
% 
%   Output:
% 
%   - gui      : A nb_saveAsPackageGUI object.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % As an nb_GUI object
        parent      = [];
        
        % As an nb_graph_package object
        package     = [];
        
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
        
        function gui = nb_saveAsPackageGUI(parent,package)
            
            gui.parent  = parent;
            gui.package = package;
            makeGUI(gui);
            
        end
        
    end
    
    methods (Access=protected,Hidden=true)
        
       varargout = makeGUI(varargin) 
       
       varargout = saveRoutine(varargin) 
        
    end

end
