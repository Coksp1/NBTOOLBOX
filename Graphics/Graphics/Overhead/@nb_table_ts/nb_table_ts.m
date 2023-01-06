classdef nb_table_ts < nb_table_data_source
% Syntax:
%     
% obj = nb_table_ts(data)
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
%   obj = nb_table_ts(data)
% 
%   Input:
%
%   - data : An object of class nb_ts
% 
%   Output:
% 
%   - obj  : An object of class nb_table_ts
% 
% See also: 
% nb_table_data_source.graph
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The dates of the table, as a cellstr. This option will overrun
        % the startTable and endTable properties.
        datesOfTable            = {};
        
        % Sets the end date of the table. Either as string or an object 
        % which is of a subclass of the nb_date class. If the given date 
        % is after the end date of the data, the data will be appended 
        % with nan values. I.e. the table will be blank for these dates.        
        endTable                = '';    
        
        % Sets the start table of the graph. Must be a string or an 
        % object which of a subclass of the nb_date class. If this 
        % date is before the start date of the data, the data will be 
        % expanded with nan (blank values) for these periods.        
        startTable              = ''; 
          
        % Sets the variables to be part of the table       
        variablesOfTable        = {};

    end

    properties(Access=protected,Hidden=true)
        
        manuallySetEndTable         = 0;                % Indicator if the endTable property has been set manually
        manuallySetStartTable       = 0;                % Indicator if the startTable property has been set manually
        
    end
    
    methods
        
        function obj = nb_table_ts(data) 
        
            if nargin < 1
                data = [];
            end
            
            if isempty(data)
                data = nb_ts;
            end

            if ~isa(data,'nb_ts')
               error([mfilename ':: The data input must be an object of class nb_ts.']) 
            end
            
            obj@nb_table_data_source(data);
            
        end
        
        function out = get.endTable(obj)
            
            if (~obj.manuallySetEndTable || isempty(obj.endTable)) && ~obj.returnLocal
                out = obj.DB.getRealEndDate('nb_date');
            elseif ischar(obj.endTable) && ~obj.returnLocal
                ind = strfind(obj.endTable,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.endTable,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.endTable);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch %#ok<CTCH>
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property endGraph with local variable notation.'])
                    end
                end
            else
                out = obj.endTable;
            end
            
        end
        
        function out = get.startTable(obj) 
            
            if (~obj.manuallySetStartTable  || isempty(obj.startTable)) && ~obj.returnLocal
                out = obj.DB.getRealStartDate('nb_date');
            elseif ischar(obj.startTable) && ~obj.returnLocal
                ind = strfind(obj.startTable,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.startTable,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.startTable);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch %#ok<CTCH>
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property startGraph with local variable notation.'])
                    end
                end
            else
                out = obj.startTable;
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
                message = 'Cannot include the data type of the updated data in a time-series table. Save it to a new dataset and create a new table with that dataset!';
                return

            else
                
                % Check the date properties
                %---------------------
                if isempty(newDataSource.frequency)
                    freq = 0;
                else
                    freq = newDataSource.frequency;
                end

                if obj.DB.frequency ~= freq || isempty(newDataSource)

                    if isempty(newDataSource)
                        message = 'The changed data is empty. All data dependent settings will be set to default values!';
                    else
                        message = 'The frequency of the data has changed. All the settings that relates to dates will be set to default!';
                    end

                    s.properties.endTable     = '';
                    s.properties.startTable   = '';
                    s.properties.datesOfTable = {};

                else

                    if ~isempty(obj.datesOfTable)

                        datesTP = obj.datesOfTable;
                        ind     = ismember(datesTP,dates(newDataSource));
                        datesTR = datesTP(~ind);
                        if ~isempty(datesTR)
                            newMessage = ['Some of the dates of the table will be removed by your changes to the data; ' toString(datesTR) '.'];
                            message    = nb_addMessage(message,newMessage);
                            s.properties.datesOfTable = datesTP(ind);                        
                        end

                    end

                    if newDataSource.endDate < obj.endTable
                        if isempty(obj.datesOfTable)
                            newMessage = ['The end date of the table is after the end date of the dataset (' newDataSource.endDate.toString() '). Reset to ' newDataSource.endDate.toString()];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.endTable = [];
                    elseif obj.endTable < newDataSource.startDate
                        s.properties.endTable = [];
                        if isempty(obj.datesOfTable)
                            newMessage = ['The end date of the table is before the start date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.endDate.toString()];
                            message    = nb_addMessage(message,newMessage);
                        end
                    end

                    if newDataSource.endDate < obj.startTable
                        s.properties.startTable = [];
                        if isempty(obj.datesOfTable)
                            newMessage = ['The start date of the table is after the end date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.startDate.toString()];
                            message    = nb_addMessage(message,newMessage);
                        end
                    elseif obj.startTable < newDataSource.startDate
                        if isempty(obj.datesOfTable)
                            newMessage = ['The start date of the table is before the start date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.startDate.toString()];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.startTable = [];
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
            
            if isempty(obj.datesOfTable)
                datOfTable = obj.startTable:obj.spacing:obj.endTable;
            else
                datOfTable = obj.datesOfTable;  
            end
            
            if nb_sizeEqual(datOfTable,[1,nan])
                datOfTable = datOfTable';
            end
            
            [indV,locV] = ismember(obj.variablesOfTable,obj.DB.variables);
            if any(~indV)
                error([mfilename ':: Cannot locate the variables; ' toString(obj.variablesOfTable(~indV))])
            end
            
            [ind,loc] = ismember(datOfTable,dates(obj.DB));
            if any(~ind)
                error([mfilename ':: Cannot locate dates; ' toString(datOfTable(~ind))])
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
            dataAsCell = [{'Time'}, obj.variablesOfTable; datOfTable, num2cell(dataT)];
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
                uimenu(selectM,'Label','Dates','Callback',{@obj.setObservationsGUI,'dates'});
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Variables','Callback',{@obj.reorderGUI,'variables'});
                uimenu(reorderM,'Label','Dates','Callback',{@obj.reorderGUI,'dates'});
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
        
            obj = nb_table_ts.unstruct(s);
            
        end

    end
    
end
