classdef nb_meanGUI < nb_methodGUI
% Description:
%
% Open up the mean dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_meanGUI(parent,data,type)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - type       : Type of mean, as a string
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        popupmenu1      = [];
        popupmenu2      = [];
        type            = 'mean';
        
    end
    
    methods
        
        function gui = nb_meanGUI(parent,data,type)
           
            gui = gui@nb_methodGUI(parent,data);
            
            if nargin < 3
                gui.type = 'mean';
            else
                gui.type = type;
            end
            
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = meanCallback(varargin)
        
    end
    
end
