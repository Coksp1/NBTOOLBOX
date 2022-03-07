classdef nb_renameGUI < nb_methodGUI
% Description:
%
% Open up the rename variable/dataset dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_renameGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : Either 'variable', 'dataset' or 'type'
% 
%   Output:
% 
%   - gui        : An object of class nb_renameGUI.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Either 'variable', 'dataset' or 'type'
        type            = '';
        
    end

    properties (Access=protected,Hidden=true)
        
        popupmenu          = [];
        editbox            = [];
        renamepopup        = [];
        idBox              = [];
        idText             = [];
        selectText         = [];
        
    end
    
    methods
        
        function gui = nb_renameGUI(parent,data,type)
           
            gui      = gui@nb_methodGUI(parent,data);
            gui.type = type;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = renameVariableCallback(varargin)
        
        varargout = popupCallback(varargin);
        
    end
    
end
