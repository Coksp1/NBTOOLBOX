classdef nb_interpolateGUI < nb_methodGUI
% Description:
%
% Interpolate variables of an nb_ts or nb_data object
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_interpolateGUI(parent,data,method)
% 
%   Input:
%
%   
% 
%   Output:
% 
%   
% 
% Written by Eyo Herstad
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Chosen method of interpolation
        method        = '';
        
    end
    
    properties (Access=protected,Hidden=true)
    
        popup     = [];
        
    end
    
    methods
        
        function gui = nb_interpolateGUI(parent,data)
           
            gui      = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = interpolateCallback(varargin)
                
    end
    
end
