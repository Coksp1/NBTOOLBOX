classdef nb_editTextGUI < handle
% Description:
%
% This class makes a GUI for editing the text information of graphs.
%
% Constructor:
%
%   gui = nb_editTextGUI(plotter)
% 
%   Input:
%
%   - plotter : Parent as a nb_GUI object.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Per Bjarne Bye
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the GUI object. If empty, user can import the
        % information.
        parent       = [];
        
        % The struct that holds all the information. Can be exported to a
        % .mat file and imported independently to the session.
        infoStruct   = struct();
        
        % List of nb_graph_adv to operate on.
        graphNames   = [];
        
        % The property storing the current graph as a graph object.
        graphObj     = [];
        
        % Handle to the GUI figure
        figureHandle = [];
        
        % The property storing the loaded objects name.
        name         = '';
        
    end
    
    properties(Access=protected)
        
        % Edit Boxes
        editBox1     = [];
        editBox2     = [];
        editBox3     = [];
        editBox4     = [];
        editBox5     = [];
        editBox6     = [];
        editBox7     = [];
        editBox8     = [];
        % Plotter properties (if panel, plotter(1))
        editBox9     = [];
        editBox10    = [];
        editBox11    = [];
        editBox12    = [];
        % Plotter(2) properties
        editBox13    = [];
        editBox14    = [];
        editBox15    = [];
        editBox16    = [];
        uiText1      = [];
        uiText2      = [];
        uiText3      = [];
        uiText4      = [];
        uiText5      = [];
        uiText6      = [];
        
        % Handle to the popupmenu to select the graphs from.
        popup = [];
        
    end
    
    methods
        
        function gui = nb_editTextGUI(obj)
        % Constructor
               
            if nargin < 1
                % Open import dialogue if editTextGUI is opened outside DAG
                infoStruct     = nb_editTextGUI.importTextStruct();
                gui.infoStruct = infoStruct;
            else
                % Build GUI with information in session file
                gui.parent     = nb_getParentRecursively(obj);
                gui.graphNames = nb_editTextGUI.getAdvGraphs(obj.graphs);
                if isempty(gui.graphNames)
                    nb_errorWindow(['Looks like there are no advanced graphs ',...
                        'in the current session. If you want to edit text on ',...
                        'another session. Call nb_editTextGUI() in the command ',...
                        'window and import the .mat file with the text information. ',...
                        'Alternatively, import a session or create some advanced ',...
                        'graphs and try again!']);
                    return
                end
                gui.infoStruct = nb_editTextGUI.createStruct(obj,gui.graphNames);
            end
            makeGUI(gui)
        end
        
    end
    
    methods(Static=true)
        
        varargout = createStruct(varargin)
        
        varargout = getAdvGraphs(varargin)
        
        varargout = importTextStruct(varargin)
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = addLeftColumnGUI(varargin)
        
        varargout = addUpdateButtonGUI(varargin)
        
        varargout = changeGraph(varargin)
        
        varargout = helpEditTextGUICallback(varargin)
        
        varargout = addSingleFieldGUI(varargin)
        
        varargout = addPanelFieldGUI(varargin)
        
        varargout = exportTextStruct(varargin)
        
        varargout = importTextStructCallback(varargin)        
        
        varargout = saveToSession(varargin)
        
        varargout = setTextInfo(varargin)
        
    end
    
end
