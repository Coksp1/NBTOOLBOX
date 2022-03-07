classdef nb_syncLocalVariablesGUI < handle
% Description:
%
% A class to sync local variables from loaded graph object with the
% local variables stored in the main program (nb_GUI).
%
% If conflicting the user gets the opportunity to selected if 
% he/she wants to keep the existing definitions or the loaded one. 
%
% Constructor:
%
%   gui = nb_syncLocalVariablesGUI(parent,object,funcHandle)
% 
%   Input:
%
%   - parent     : As an nb_GUI object
%
%   - object     : As a nb_ts, nb_graph, nb_graph_adv, nb_graph_subplot 
%                  or nb_graph_package.
%
%   - funcHandle : Function handle to call when objects needs to be synced.
% 
%   Output:
% 
%   - gui    : An nb_syncLocalVariablesGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A MATLAB figure handle
        figureHandle        = [];
        
        % Handle to the function to excecute when syncing is done.
        funcHandle          = [];
        
        % As an nb_GUI object
        parent              = [];
        
        % The object to sync. Either a nb_graph, a nb_graph_adv  
        % a nb_ts or a nb_graph_adv object
        object              = [];
        
    end
    
    properties(Access=protected,Hidden=true)
        
        conflictingNames = {};
        existing         = {};
        added            = {};  
        table            = [];
        
    end
    
    events
       
        syncDone
        
    end
    
    methods
        
        function gui = nb_syncLocalVariablesGUI(parent,object,funcHandle)
           
            if nargin < 3
                funcHandle = [];
            end
            gui.funcHandle = funcHandle;
            gui.parent     = parent;
            gui.object     = object;
            somethingToSync(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)   
        varargout = somthingToSync(varargin)
        varargout = saveRoutine(varargin)
        varargout = close(varargin)
        
    end
    
end
