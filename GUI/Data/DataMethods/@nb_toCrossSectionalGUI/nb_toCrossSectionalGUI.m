classdef nb_toCrossSectionalGUI < nb_methodGUI
% Description:
%
% Convert an nb_ts object to an nb_cs object
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_toCrossSectionalGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - gui        : An object of this class.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (Access=protected,Hidden=true)
    
        pop1       = [];
        pop2       = [];
        
    end
    
    methods
        
        function gui = nb_toCrossSectionalGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = convertCallback(varargin)
                
    end
    
end
