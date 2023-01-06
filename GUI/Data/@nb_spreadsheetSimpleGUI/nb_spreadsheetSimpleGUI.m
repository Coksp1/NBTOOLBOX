classdef nb_spreadsheetSimpleGUI < nb_spreadsheetGUI
% Description:
%
% A class for the spreadsheet view of the data
%
% Superclasses:
%
% handle, nb_spreadsheetGUI
%
% Constructor:
%
%   gui = nb_spreadsheetSimpleGUI(parent,data)
% 
%   Input:
%
%   - parent   : An object of class nb_GUI
%
%   - data     : The data to display in the spreadsheet. As an 
%                nb_ts or nb_cs object.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As an  
%                nb_spreadsheetGUI object.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_spreadsheetSimpleGUI(parent,data,currentPage)
        % Constructor
            if nargin < 3
                currentPage = 1;
                if nargin < 2
                    data = [];
                end
            end
        
            % Call superclass constructor
            gui = gui@nb_spreadsheetGUI(parent,data);
            
            % If given, set the page.
            gui.page = currentPage;
            updateTable(gui);
            
        end
                
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
    end
    
end

