classdef nb_viewInfoSpreadsheetGUI < handle
% Description:
%
% This class makes a GUI for viewing the information of graphs in 
% session file/graph packages in a spreadsheet format with possibility 
% of exporting it to excel.
%
% Constructor:
%
%   gui = nb_viewInfoSpreadsheetGUI(plotter)
% 
%   Input:
%
%   - plotter : Parent as a nb_GUI or nb_graph_package object.
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
        
        % Handle to the GUI figure
        figureHandle = [];
        
        % The name of the GUI window.
        name         = '';
        
        % The info to be displayes as a cellstr.
        info         = {};
        
        % The handle to the table (info spreadsheet)
        table        = [];
        
        % If spreadsheet is opened for a package this is true. From session
        % file is false.
        package      = true;
        
    end
    
    methods
        
        function gui = nb_viewInfoSpreadsheetGUI(obj)
        % Constructor
            if isa(obj,'nb_graph_packageGUI')
                gui.parent  = obj.parent;
                gui.name    = obj.packageName;
                gui.package = true;
                gui.info    = getInfoSpreadsheetPackage(obj);
                
            elseif isa(obj,'nb_GUI')
                gui.parent  = obj;
                gui.name    = 'Spreadsheet';
                gui.package = false;
                gui.info    = getInfoSpreadsheetSession(obj);
            else
                nb_errorWindow('Input must be either a nb_graph_package or a nb_GUI object')
                return
            end
            makeGUI(gui);
        end

        
    end
    
    methods(Static=true,Hidden=true)
       
        varargout = getVariablesAndSources(varargin)
        
        varargout = helpInfoSpreadsheetCallback(varargin)
        
    end
    
    methods(Access=protected,Hidden=true)
       
        varargout = makeGUI(varargin)
        
        varagour = exportInfoSpreadsheet2Excel(varargin)
      
    end
    
end
