classdef nb_permuteGUI < nb_methodGUI
% Description:
%
% Permute object GUI
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_permuteGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
% 
%   Output:
% 
%   - gui        : An object of class nb_permuteGUI.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    methods
        
        function gui = nb_permuteGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = okCallback(varargin)
                
    end
    
end
