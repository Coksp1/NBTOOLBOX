classdef nb_johansenTestGUI < nb_methodGUI
% Description:
%
%   Performs a johansen cointegration test
%
% Constructor:
%   
%   gui = nb_johansenTestGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI.
%
%   - data   : The data that you want to use the unit root method on.
%
%   Output:
%   
%   - gui: The handle of the gui object, as a nb_johansenTestGUI object. 
%
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties

       % Handle of the window
        jtestWindow = [];
    end

    properties (Access = protected, Hidden = true)
        
        % Components of lag panel
        lagPanelComponents = struct();
        
        % Additional options panel components
        optionPanelComponents = struct();
        
        % Deterministic assumptions panel components
        determPanelComponents = struct();
        
        % Variables selection panel
        panels                = struct();
        
        % Variables selection panel components
        varSelPanelComponents = struct();
        
    end
    
    methods
        % Constructor
        function gui = nb_johansenTestGUI(parent,data)
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
        
    end
    
end

