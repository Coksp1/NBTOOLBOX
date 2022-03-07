classdef nb_toCellGUI < nb_methodGUI
% Description:
%
% Convert a nb_ts, nb_cs or nb_data object to a nb_cell object.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_toCellGUI(parent,data)
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

    properties (Access=protected,Hidden=true)
    
        format       = [];
        strip        = [];
        
    end
    
    methods
        
        function gui = nb_toCellGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = convertCallback(varargin)
                
    end
    
end
