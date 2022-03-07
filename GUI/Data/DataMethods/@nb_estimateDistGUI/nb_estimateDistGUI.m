classdef nb_estimateDistGUI < nb_methodGUI
% Description:
%
% Open up the estimate distribution dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_estimateDistGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        pop1          = [];
        pop2          = [];
        pop3          = [];
        figureHandle  = [];
        list1         = [];
        rball         = [];
        
    end
    
    methods
        
        function gui = nb_estimateDistGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
    end
    
end
