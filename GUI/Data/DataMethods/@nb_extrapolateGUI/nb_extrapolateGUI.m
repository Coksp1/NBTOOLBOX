classdef nb_extrapolateGUI < nb_methodGUI
 % Description:
%
% Open up dialog window to extrapolate the dataset.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_extrapolateGUI(parent,data)
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

    properties (Access = protected, Hidden = true)
        figureHandle = [];
        components = struct();       
    end
    
    methods  
        function gui = nb_extrapolateGUI(parent, data)        
            gui = gui@nb_methodGUI(parent,data);
            makeGUI(gui);            
        end
    end
    
    methods(Access=protected,Hidden=true)        
        varargout = makeGUI(varargin)
        varargout = updateGUI(varargin)
        varargout = extrapolateCallback(varargin)               
    end
    
end
