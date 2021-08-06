classdef nb_generateDataGUI < nb_methodGUI
% Description:
%
% Generate random nb_ts, nb_data or nb_cs data
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_generateDataGUI(parent,data)
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
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected, Hidden = true)
        % GUI Components
        figureHandle = [];
        
        startBox = [];
        numOfVarsBox = [];
        numOfPagesBox = [];
        numOfTypesBox = [];
        numOfObsBox = [];
        distributionNameUI = [];
        
        % Defaults
        distribution = nb_distribution('type', 'uniform');
    end
    
    methods
        function gui = nb_generateDataGUI(parent, data)
            gui = gui@nb_methodGUI(parent, data);
            makeGUI(gui);
        end
        
        function set.distribution(gui, distribution)
            gui.distribution = distribution;
            % Update distribution name in GUI
            set(gui.distributionNameUI, 'string', distribution.name);
        end
    end
    
    methods(Access=protected,Hidden=true)
        varargout = makeGUI(varargin)
        varargout = selectDistributionCallback(varargin)
        varargout = generateDataCallback(varargin)         
    end
    
end
