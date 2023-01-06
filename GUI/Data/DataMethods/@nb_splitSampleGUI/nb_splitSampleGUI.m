classdef nb_splitSampleGUI < nb_methodGUI
% Description:
%
% Split a sample into subsamples of desired length
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_splitSampleGUI(parent,data)
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
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
    end
    
    properties (Access=protected,Hidden=true)
        subsampleLengthBox = [];        
    end
    
    methods
        function gui = nb_splitSampleGUI(parent,data)
            gui      = gui@nb_methodGUI(parent,data);
            makeGUI(gui);
        end 
    end
    
    methods(Access=protected,Hidden=true)   
        varargout = makeGUI(varargin)
        varargout = splitSampleCallback(varargin)          
    end
    
end
