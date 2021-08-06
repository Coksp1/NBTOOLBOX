classdef nb_saveAsDataGUI < handle
% Description:
%
% Saves a dataset object stored as an nb_dataSource object to the
% main program. Opens up a dialog box to give it a save name.
% Will trigger an saveNameSelected event.
%
% Constructor:
%
%   gui = nb_saveAsDataGUI(parent,data)
% 
%   Input:
%
%   - parent   : As an nb_GUI object.
% 
%   - data     : Either a nb_modelDataSource, a nb_ts or a nb_cs object.
% 
%   Output:
% 
%   - Dataset stored in the main program. And a saveNameSelected
%     event triggered.
% 
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % As an nb_GUI object
        parent      = [];
        
        % As a nb_modelDataSource, a nb_ts or a nb_cs object
        data        = [];
        
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
        
        function gui = nb_saveAsDataGUI(parent,data)
            
            gui.parent = parent;
            gui.data   = data;
            makeGUI(gui);
            
        end
        
    end
    
    methods (Access=protected,Hidden=true)
        
       varargout = makeGUI(varargin) 
       varargout = saveRoutine(varargin) 
        
    end

end
