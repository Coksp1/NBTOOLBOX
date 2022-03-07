classdef (Abstract) nb_historyGUI < handle
% Description:
%
% Subclass this class in order to add undo/redo functionality to a GUI 
% class.
%
% Typical usage:
%
%   In your constructor:
%       gui@nb_historyGUI({'loggedVar1', 'loggedVar2'});
%
%   In your makeGUI method:
%       editMenu = uimenu(figureHandle, 'Label', 'Edit');
%       gui.makeHistoryGUI(editMenu, @gui.updateGUI);
%
%   You may also want to use obj.updateHistoryGUI() to force an update
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   obj = nb_historyGUI(historyVariables)
% 
%   Input:
%
%   - historyVariables : A cellstr with the properties to store for 
%                        undo/redo functionality. 
% 
%   Output:
% 
%   - obj              : An object of class nb_historyGUI.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        % Cell array of names of variables to log
        historyVariables = {};
        
        % Function to call after undo/redo operations
        historyUpdateCallback = @()[];
        
        % Graphic handles
        undoMenuItem = [];
        redoMenuItem = [];
    end

    properties (Access = private)
        % Struct with variable names as fieldnames and 
        % variable values as values
        history = struct();
        
        % Current index in history
        historyIndex = 0;
    end
    
    methods
        
        function obj = nb_historyGUI(historyVariables)
            obj.historyVariables = historyVariables;
        end
        
        function makeHistoryGUI(obj, editMenu, historyUpdateCallback)
            obj.undoMenuItem = uimenu(...
                'Parent', editMenu, ...
                'Label', 'Undo', ...
                'Callback', @obj.undo, ...
                'Accelerator', 'z', ...
                'interruptible', 'off');
            
            obj.redoMenuItem = uimenu(...
                'Parent', editMenu, ...
                'Label', 'Redo', ...
                'Callback', @obj.redo, ...
                'Accelerator', 'y', ...
                'interruptible', 'off');
            
            obj.historyUpdateCallback = historyUpdateCallback;
            
            obj.updateHistoryGUI();
        end
        
        function updateHistoryGUI(obj)
            set(obj.undoMenuItem, 'Enable', nb_conditional(obj.historyIndex > 1, 'on', 'off'));
            set(obj.redoMenuItem, 'Enable', nb_conditional(obj.historyIndex < length(obj.history), 'on', 'off'));
        end
        
        function addToHistory(obj)
            obj.historyIndex = obj.historyIndex + 1;
            
            for i = 1:length(obj.historyVariables)
               variable = obj.historyVariables{i};
               obj.history(obj.historyIndex).(variable) = nb_copy(obj.(variable));
            end

            obj.clearRedoHistory(); 
            obj.updateHistoryGUI();
        end
        
        function clearHistory(obj)
            obj.history = [];
            obj.historyIndex = 0;
            obj.addToHistory();
        end
        
        function clearRedoHistory(obj)
            obj.history(obj.historyIndex + 1:end) = [];
            obj.updateHistoryGUI();
        end

        function undo(obj, varargin)
            assert(obj.historyIndex > 1);
            obj.historyIndex = obj.historyIndex - 1;
            obj.updateHistory();
        end
        
        function redo(obj, varargin)
            assert(obj.historyIndex < length(obj.history));
            obj.historyIndex = obj.historyIndex + 1;
            obj.updateHistory();
        end
        
    end
    
    methods (Access = private)
        
        function updateHistory(obj)
            obj.updateVariables();
            obj.updateHistoryGUI();
            obj.historyUpdateCallback();
        end
        
        function updateVariables(obj)
            cellfun(@assign, fieldnames(obj.history));        
            function assign(field)
                obj.(field) = obj.history(obj.historyIndex).(field);
            end
        end  
  
    end
    
end

