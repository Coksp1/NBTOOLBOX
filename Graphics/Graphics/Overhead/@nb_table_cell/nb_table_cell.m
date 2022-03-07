classdef nb_table_cell < nb_table_data_source
% Syntax:
%     
% obj = nb_table_cell(data)
% 
% Superclasses:
% 
% nb_table_data_source, nb_graph_obj, handle, 
%         
% Description:
%
% A class for displaying data stored in a cell in a table.
%
% Constructor:
%
%   obj = nb_table_cell(data)
% 
%   Input:
%
%   - data : An object of class cell
% 
%   Output:
% 
%   - obj  : An object of class nb_table_cell
% 
% See also: 
% nb_table_data_source.graph
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_table_cell(data) 
        
            if nargin < 1
                data = {};
            end

            if ~iscell(data) && ~isa(data,'nb_cell')
                error([mfilename ':: The data input must be a cell or a nb_cell object.'])
            end
            obj@nb_table_data_source(data);
            
        end
        
    end
    
    methods(Hidden=true)
        
        function s = saveobj(obj)
        % Overload how the object is saved to a .MAT file
        
            s = struct(obj);
        
        end

        function [message,retcode,s] = updatePropsWhenReset(obj,newDataSource)
           
            retcode = 0;
            s       = struct('properties',struct);
            message = '';
            if ~isa(newDataSource,class(obj.DB))
                
                retcode = 1;
                message = 'Cannot include the data type of the updated data in a cell table.';
                return

            end
            
        end
        
        function dataAsCell = getDataAsCell(obj,strip) %#ok<INUSD>
            
            if isempty(obj.page)
                p = 1;
            else
                p = obj.page;
            end
            
            if isa(obj.DB,'nb_cell')
                if p > size(obj.DB.data,3)
                    error([mfilename ':: The page property is set to a page that does not exists.'])
                end
                dataAsCell = obj.DB.cdata(:,:,p);
            else
                if p > size(obj.DB,3)
                    error([mfilename ':: The page property is set to a page that does not exists.'])
                end
                dataAsCell = obj.DB(:,:,p);
            end
 
        end
        
        function addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
           
            if ~isempty(graphMenu)
                uimenu(graphMenu,'Label','Notes','separator','on','Callback',@obj.editNotes);
            end
            
            if ~isempty(dataMenu)
                uimenu(dataMenu,'Label','Page','Callback',@obj.setPageGUI);
                uimenu(dataMenu,'Label','Spreadsheet','Callback',@obj.spreadsheetGUI);
                uimenu(dataMenu,'Label','Update','separator','on','Callback',@obj.updateGUI);
            end

            uimenu(propertiesMenu,'Label','Title','tag','title','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','Footer','tag','xlabel','Callback',@obj.addAxesTextGUI);
%             yLab = uimenu(propertiesMenu,'Label','Y-Axis Label','Callback','');
%                 uimenu(yLab,'Label','Left','tag','yLabel','Callback',@obj.addAxesTextGUI);
%                 uimenu(yLab,'Label','Right','tag','yLabelRight','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','Look Up','Callback',@obj.lookUpGUI);  
            uimenu(propertiesMenu,'Label','General','Callback',@obj.generalPropertiesGUI);  

            uimenu(annotationMenu,'Label','Text Box','Callback',@obj.addTextBox);
            uimenu(annotationMenu,'Label','Rectangle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Circle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Arrow','Callback',@obj.addArrow);
            uimenu(annotationMenu,'Label','Text Arrow','Callback',@obj.addTextArrow);
            uimenu(annotationMenu,'Label','Curly Brace','Callback',@obj.addCurlyBrace);
            
        end
             
    end

    methods(Static=true)

        varargout = unstruct(varargin)

        function obj = loadobj(s)
        % Overload how the object is loaded from a .mat file
        
            obj = nb_table_cell.unstruct(s);
            
        end

    end
    
end
