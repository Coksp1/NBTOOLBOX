classdef (Abstract) nb_tableEditGUI < handle
% Description:
%
% This is a class for making it possible to look and edit at the methods 
% that is called on the nb_dataSource object
%
% Constructor:
%
%   No constructor.
% 
% Written by Kenneth Sæterhagen Paulsen   
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = protected)
        
        % Index of selected row.
        index               = [];
        
        % The selected cells of the table
        selectedCells       = [];
        
        % Cell matrix displayed
        tableData           = {''};
        
        % Handle to the table of the GUI window
        table               = [];
        
    end
    
    methods
         
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = addRow(varargin)
        varargout = deleteRow(varargin)
        varargout = getSelectedCells(varargin)
         
    end
    
    methods(Access=protected,Hidden=true,Abstract=true)
        
        varargout = addCallback(varargin)
        varargout = cellEdit(varargin)
        varargout = deleteCallback(varargin)
         
    end
    
end
