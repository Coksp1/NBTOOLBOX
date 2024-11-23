classdef nb_unitRootGUI < nb_methodGUI
% Description:
%   Takes the unit root of the data 
%
% Constructor:
%   
%   gui = nb_unitRootGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI.
%
%   - data   : The data that you want to use the unit root method on.
%
%   Output:
%   
%   - gui    : The handle of the gui object, as a nb_unitRoot object.
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties

       % Handle of the window
        unitRootWindow = [];
    end

    properties (Access = protected, Hidden = true)
        
        % Popupmenu with different types
        testTypeBox = [];
        
        % Panels to be switched on/off for different types of tests
        unitRootPanels = struct();
        
        % Components of lag panel
        lagPanelComponents = struct();
        
        % Components of bandwidth panel
        bandwidthComponents = struct();
        
        % Level and intercept components
        levelPanelComponents = struct();
        interceptPanelComponents = struct();
        
        % Window components
        windowComponents = struct();
        
    end
    
    methods
        % Constructor
        function gui = nb_unitRootGUI(parent,data)
            gui = gui@nb_methodGUI(parent,data);
            gui.parent  = parent;
            gui.data    = data;
            makeGUI(gui);
        end
    end
    
    methods(Access=protected)
        
        varargout = okCallback(varargin)
        
        varargout = switchPanel(varargin)
        
        varargout = makeGUI(varargin);
        
        varargout = bandwidthCallback(varargin);
        
        varargout = lagLengthCallback(varargin);
        
        varargout = exit(varargin);
        
    end
    
end

