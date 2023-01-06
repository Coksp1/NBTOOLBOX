classdef nb_DataCollection
% Description:
%
% A class for storing nb_ts, nb_cs and/or nb_data objects
%
% Constructor:
%
%   obj = nb_DataCollection(filename)
% 
%   Input:
%
%   - filename : A string with the names of an excel spreadsheet.
%
%                If given this input will be given to the 
%                nb_readExcelMoreSheets, so see the documentation
%                of this function for more one the needed format 
%                of the excel spreadsheet.
%
%                If this input is not given, a empty 
%                nb_DataCollection object is constructed.
% 
%   Output:
% 
%   - obj       : An object of class nb_DataCollection
% 
%   Examples:
%
%   obj = nb_DataCollection();
%   obj = nb_DataCollection('excelFileName');
% 
% See also: 
% nb_ts, nb_cs, nb_readExcelMoreSheets
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties

        % A cellstr with the identifiers of the stored objects.
        objectsID = {};     
        
        % An object of class nb_List storing the data objects
        list      = nb_List();  
        
    end

    methods
        
        %{
        -------------------------------------------------------------------
        Constructor of the nb_DataCollection
        -------------------------------------------------------------------
        Optional input:
        
        - filename : A string with the names of an excel spreadsheet. 
        
        -------------------------------------------------------------------
        %}
        function obj = nb_DataCollection(filename)
            
            if nargin ~=0 
                
                obj = nb_readExcelMoreSheets(filename);
                
            end
            
        end

        
        varargout = add(varargin)

        varargout = remove(varargin)
        
        varargout = get(varargin)

        varargout = saveData(varargin)
            
        varargout = merge(varargin)

        varargout = convert(varargin)

        varargout = disp(varargin)
        
        varargout = reset(varargin)
        
        varargout = getVariables(varargin)
            
    end

end
