classdef nb_engleGrangerTestGUI < nb_methodGUI
% Description:
%
%   Takes the unit root of the data 
%
% Constructor:
%   
%   gui = nb_engleGrangerTestGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI.
%
%   - data   : An object of class nb_ts.
%
%   Output:
%   
%   gui: The handle of the gui object, as a nb_unitRoot object.
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties

       % Handle of the window
        egTestWindow = [];
    end

    properties (Access = protected, Hidden = true)
        
        % Popupmenu with different types
        testTypeBox              = [];
        
        % Panels to be switched on/off for different types of tests
        unitRootPanels           = struct();
        
        % Components of lag panel
        lagPanelComponents       = struct();
        
        % Components of bandwidth panel
        bandwidthComponents      = struct();
        
        % Level and intercept components
        levelPanelComponents     = struct();
        interceptPanelComponents = struct();
        
        % Additional options panel components
        optionPanelComponents    = struct();
        
        % Variable selection panel components
        varSelPanelComponents    = struct();
        
    end
    
    methods
        % Constructor
        function gui = nb_engleGrangerTestGUI(parent,data)
            gui         = gui@nb_methodGUI(parent,data);
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
        
        varargout = switchBackCallback(varargin);
        
        varargout = switchToVarSelCallback(varargin);
         
        varargout = varSelCallback(varargin);
        
    end
    
end

