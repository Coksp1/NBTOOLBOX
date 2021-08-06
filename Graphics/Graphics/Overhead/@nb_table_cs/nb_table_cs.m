classdef nb_table_cs < nb_table_data_source
% Syntax:
%     
% obj = nb_table_cs(data)
% 
% Superclasses:
% 
% nb_table_data_source, nb_graph_obj, handle, 
%         
% Description:
%
% A class for displaying time-series data in a table.
%
% Constructor:
%
%   obj = nb_table_cs(data)
% 
%   Input:
%
%   - data : An object of class nb_cs
% 
%   Output:
% 
%   - obj  : An object of class nb_table_cs
% 
% See also: 
% nb_table_data_source.graph
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A cellstr with the types to display in the table
        typesOfTable            = {};
            
        % Sets the variables to be part of the table       
        variablesOfTable        = {};

    end
    
    methods
        
        function obj = nb_table_cs(data) 
        
            if nargin < 1
                data = [];
            end

            if isempty(data)
                data = nb_cs;
            end

            if ~isa(data,'nb_cs')
               error([mfilename ':: The data input must be an object of class nb_cs.']) 
            end

            obj@nb_table_data_source(data);
            
        end
        
        function out = get.typesOfTable(obj)
            
           if isempty(obj.typesOfTable) && ~obj.returnLocal
               out = obj.DB.types;
           else
               out = obj.typesOfTable;
           end
            
        end
        
        function out = get.variablesOfTable(obj)
            
           if isempty(obj.variablesOfTable) && ~obj.returnLocal
               out = obj.DB.variables;
           else
               out = obj.variablesOfTable;
           end
            
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
                message = 'Cannot include the data type of the updated data in a cross-sectional table. Save it to a new dataset and create a new table with that dataset!';
                return

            else
                
                % Check the types properties
                %-------------------------------
                if ~isempty(obj.typesOfTable)

                    typesTP = obj.typesOfTable;
                    ind     = ismember(typesTP,newDataSource.types);
                    typesTR = typesTP(~ind);
                    if ~isempty(typesTR)
                        newMessage = ['Some of the types of the table will be removed by your changes to the data; ' toString(typesTR) '.'];
                        message    = nb_addMessage(message,newMessage);
                        s.properties.typesOfTable = typesTP(ind);                        
                    end

                end

                % Check the variables properties
                %-------------------------------
                if ~isempty(obj.variablesOfTable)
                
                    varsTP   = obj.variablesOfTable;
                    ind      = ismember(varsTP,newDataSource.variables);
                    varsTR   = varsTP(~ind);
                    if ~isempty(varsTR)
                        newMessage = ['Some of the variables of the table will be removed by your changes to the data; ' toString(varsTR) '.'];
                        message    = nb_addMessage(message,newMessage);
                        s.properties.variablesOfTable = varsTP(ind);                        
                    end
                    
                end

            end
            
        end
        
        function dataAsCell = getDataAsCell(obj,strip)
            
            if nargin < 2
                strip = 'off';
            end
            
            [indV,locV] = ismember(obj.variablesOfTable,obj.DB.variables);
            if any(~indV)
                error([mfilename ':: Cannot locate the variables; ' toString(obj.variablesOfTable(~indV))])
            end
            
            [ind,loc] = ismember(obj.typesOfTable,obj.DB.types);
            if any(~ind)
                error([mfilename ':: Cannot locate dates; ' toString(obj.typesOfTable(~ind))])
            end
            
            if isempty(obj.page)
                p = 1;
            else
                p = obj.page;
            end
            
            if p > obj.DB.numberOfDatasets
                error([mfilename ':: The page property is set to a page that does not exists.'])
            end
            
            dataT      = obj.DB.data(loc,locV,p);
            dataAsCell = [{'Types'}, obj.variablesOfTable; obj.typesOfTable', num2cell(dataT)];
            if strcmpi(strip,'on')
                ind         = [false, all(~isfinite(dataT),2)];
                dataAsCell  = dataAsCell(~ind,:); 
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

            selectM = uimenu(propertiesMenu,'Label','Select');
                uimenu(selectM,'Label','Variables','Callback',{@obj.setObservationsGUI,'variables'});
                uimenu(selectM,'Label','Types','Callback',{@obj.setObservationsGUI,'types'});
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Variables','Callback',{@obj.reorderGUI,'variables'});
                uimenu(reorderM,'Label','Types','Callback',{@obj.reorderGUI,'types'});
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
        
            obj = nb_table_cs.unstruct(s);
            
        end
        
    end
    
end
