classdef nb_selectDataMethodGUI
% Description:
%
% Make the user select a method from a list to act on a nb_dataSource 
% object.
%
% Constructor:
%
%   gui = nb_selectDataMethodGUI(parent)
% 
%   Input:
%
%   - parent : A nb_spreadsheetGUI object.
% 
%   Output:
% 
%   - gui    : A nb_selectDataMethodGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
    
        % Handle to the window
        figureHandle    = [];
        
        % As an nb_spreadsheetGUI object
        parent          = [];
        
    end

    properties (Access=protected,Hidden=true)
        
        listbox         = [];
        
    end
    
    methods
        
        function gui = nb_selectDataMethodGUI(parent)
            
            gui.parent = parent;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin) 
        varargout = methodSelectCallback(varargin)
        
    end
    
end

