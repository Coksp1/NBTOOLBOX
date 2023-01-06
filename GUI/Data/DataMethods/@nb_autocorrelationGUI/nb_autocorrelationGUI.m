classdef nb_autocorrelationGUI < handle
% Description:
%
% Open up dialog window to calculate autocorrelations.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_autocorrelationGUI(parent,data)
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        % Handle of parent
        parent = [];
        
        % Handle to figure
        figure = '';
        
        % Handle to data
        data = [];
        
        % Handle to components
        variableBox  = [];
        endDateBox   = [];
        startDateBox = [];
        nLagsBox     = [];
        alfaBox      = [];
        methodBox    = [];
        typeBox      = [];
        algorithmBox = [];
        maxMABox     = [];
        maxARBox     = [];
        criteriaBox  = [];
    end
    
    methods
        function gui = nb_autocorrelationGUI(parent,data)
            gui.parent = parent;
            gui.data = data;
            
            makeGUI(gui);
        end
    end
    methods ( Access = protected)
        
        varargout = makeGUI(varargin)
        
        varargout = makeGraphCallback(varargin)
        
        varargout = popupCallback(varargin)
        
    end
    
  
    
end

