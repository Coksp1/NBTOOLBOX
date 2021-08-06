classdef nb_sortGUI < nb_methodGUI
% Description:
%
% Open up the sort dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_sortGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_dataSource.
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
        
    end
    
    methods
        
        function gui = nb_sortGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            
            if isa(gui.data,'nb_ts')
                error([mfilename ':: Cannot sort an object of class nb_ts'])
            end
            
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = sortCallback(varargin)
        
    end
    
end
