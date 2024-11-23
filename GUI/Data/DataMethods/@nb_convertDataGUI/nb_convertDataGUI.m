classdef nb_convertDataGUI < nb_methodGUI
% Description:
%
% Opens a dialog box for the user to be able to convert the 
% frequency of an nb_ts object.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_convertDataGUI(parent,data,varargin)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - varargin   : Given to the set method.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Force the frequency to convert to. As a double.
        forceFreq   = [];
          
    end
    
    properties
        
        button      = [];
        list1       = [];
        list2       = [];
        radio1      = [];
        radio2      = [];
        
    end
    
    methods
        
        function gui = nb_convertDataGUI(parent,data,varargin)
            
            gui = gui@nb_methodGUI(parent,data);
            
            % Set optional properties
            gui.set(varargin{:});
            
            % Make dialog window
            makeGUI(gui);
            
        end
        
    end
   
    methods(Access=protected,Hidden=true)
       
        varargout = makeGUI(varargin)
        
        varargout = selectFrequency(varargin)
        
        varargout = convertData(varargin)
        
    end
    
end
