classdef nb_reorderPropertyGUI < nb_methodGUI
% Description:
%
% Open up the window of datasetdialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_reorderGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
% 
%   - type       : The property to reorder, as a string.
%
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        popupmenu1      = [];
        popupmenu2      = [];
        type            = 'variables';
        
    end
    
    methods
        
        function gui = nb_reorderPropertyGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = reorderCallback(varargin)
        
    end
    
end
