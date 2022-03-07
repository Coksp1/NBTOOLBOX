classdef nb_spreadsheetAdvGUI < nb_spreadsheetGUI & nb_historyGUI
% Description:
%
% A class for the spreadsheet view of the data and where you can
% edit your data by using different defined methods.
%
% Superclasses:
%
% handle, nb_spreadsheetGUI
%
% Constructor:
%
%   gui = nb_spreadsheetAdvGUI(parent,data,openElsewhere,saveToMenuText)
% 
%   Input:
%
%   - parent         : An object of class nb_GUI
%
%   - data           : The data to display in the spreadsheet. As a nb_data, 
%                      nb_ts or nb_cs object.
%
%   - openElsewhere  : 1 if the spreadsheet is opened somewhere which 
%                      allow editing. Will change the File menu and 
%                      send a saveToGraph/saveToListener event when the 
%                      user want to save his/hers data changes to the 
%                      graph/somthing else. Default is 0.
%
%   - saveToMenuText : Text displayed in the File menu. E.g. 
%                      'Save to Graph'.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As a  
%                nb_spreadsheetAdvGUI object.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    events
    
        saveToGraph      % A event that is trigger if the user want to save his/hers data transformations to the graph.
        saveToListener   % A event that is trigger if the user want to save his/hers data transformations to the graph.
    
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_spreadsheetAdvGUI(parent,data,openElsewhere,saveToMenuText)
        % Constructor
        
            if nargin < 4
                saveToMenuText = '';
                if nargin < 3
                    openElsewhere = 0;
                    if nargin < 2
                        data = nb_ts;
                    end
                end
            end
            
            % Call the superclass constructor
            gui = gui@nb_spreadsheetGUI(parent,data,openElsewhere,saveToMenuText);
            gui@nb_historyGUI({'data'});
            gui.addToHistory();
            
            % Add the update the backup properties callback
            % when the data of the table is updated
            addlistener(gui, 'updatedData', @(varargin) gui.addToHistory());
            addlistener(gui, 'savedData', @(varargin) gui.clearHistory());
            
        end
                
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
         
        varargout = close(varargin)
        varargout = updateGUI(varargin)
        varargout = makeGUI(varargin)
        varargout = addMenuComponents(varargin)
        
    end
    
end

