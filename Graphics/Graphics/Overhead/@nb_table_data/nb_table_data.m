classdef nb_table_data < nb_table_data_source
% Syntax:
%     
% obj = nb_table_data(data)
% 
% Superclasses:
% 
% nb_table_data_source, nb_graph_obj, handle, 
%         
% Description:
%
% A class for displaying data in a table.
%
% Constructor:
%
%   obj = nb_table_data(data)
% 
%   Input:
%
%   - data : An object of class nb_data
% 
%   Output:
% 
%   - obj  : An object of class nb_table_data
% 
% See also: 
% nb_table_data_source.graph
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Sets the end obs of the table. As an integer. If the given obs 
        % is after the end obs of the data, the data will be appended 
        % with nan values. I.e. the table will be blank for these dates.        
        endTable                = [];    
        
        % A vector with the observations to display in the table, this
        % property will overrun the startTable and endTable properties.
        observationsOfTable     = [];
        
        % Sets the start obs of the graph. As an integer. If this 
        % obs is before the start obs of the data, the data will be 
        % expanded with nan (blank values) for these periods.        
        startTable              = []; 
           
        % Sets the variables to be part of the table       
        variablesOfTable        = {};

    end

    properties(Access=protected,Hidden=true)
        
        manuallySetEndTable         = 0;                % Indicator if the endTable property has been set manually
        manuallySetStartTable       = 0;                % Indicator if the startTable property has been set manually
        
    end
    
    methods
        
        function obj = nb_table_data(data) 
        
            if nargin < 1
                data = [];
            end

            if isempty(data)
                data = nb_data;
            end

            if ~isa(data,'nb_data')
               error([mfilename ':: The data input must be an object of class nb_data.']) 
            end

            obj@nb_table_data_source(data);
            
        end
        
        function out = get.endTable(obj)
            
            if (~obj.manuallySetEndTable || isempty(obj.endTable)) && ~obj.returnLocal
                out = obj.DB.getRealEndObs();
            else
                out = obj.endTable;
            end
            
        end
        
        function out = get.startTable(obj) 
            
            if (~obj.manuallySetStartTable || isempty(obj.startTable)) && ~obj.returnLocal
                out = obj.DB.getRealStartObs();
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
                message = 'Cannot include the data type of the updated data in a data table. Save it to a new dataset and create a new table with that dataset!';
                return

            else
                
                % Check the obs properties
                %---------------------------
                if isempty(newDataSource)

                    message                          = 'The changed data is empty. All data dependent settings will be set to default values!';
                    s.properties.endTable            = [];
                    s.properties.startTable          = [];
                    s.properties.observationsOfTable = {};

                else

                    if ~isempty(obj.observationsOfTable)

                        obsTP = obj.observationsOfTable;
                        ind   = ismember(obsTP,observations(newDataSource));
                        obsTR = obsTP(~ind);
                        if ~isempty(obsTR)
                            newMessage = ['Some of the observations of the table will be removed by your changes to the data; ' toString(obsTR) '.'];
                            message    = nb_addMessage(message,newMessage);
                            s.properties.observationsOfTable = obsTP(ind);                        
                        end

                    end

                    if newDataSource.endObs < obj.endTable
                        if isempty(obj.observationsOfTable)
                            newMessage = ['The end obs of the table is after the end obs of the dataset (' toString(newDataSource.endObs) '). Reset to ' toString(newDataSource.endObs)];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.endTable = [];
                    elseif obj.endTable < newDataSource.startObs
                        if isempty(obj.observationsOfTable)
                            newMessage = ['The end obs of the table is before the start obs of the dataset (' toString(newDataSource.startObs) '). Reset to ' toString(newDataSource.endObs)];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.endTable = [];
                    end

                    if newDataSource.endObs < obj.startTable
                        if isempty(obj.observationsOfTable)
                            newMessage = ['The start obs of the table is after the end obs of the dataset (' toString(newDataSource.startObs) '). Reset to ' toString(newDataSource.startObs)];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.startTable = [];
                    elseif obj.startTable < newDataSource.startObs
                        if isempty(obj.observationsOfTable)
                            newMessage = ['The start obs of the table is before the start obs of the dataset (' toString(newDataSource.startObs) '). Reset to ' toString(newDataSource.startObs)];
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
            
            if isempty(obj.observationsOfTable)
                obsOfTable = obj.startTable:obj.spacing:obj.endTable;
            else
                obsOfTable = obj.observationsOfTable;  
            end
            
            if nb_sizeEqual(obsOfTable,[1,nan])
                obsOfTable = obsOfTable';
            end
            
            [indV,locV] = ismember(obj.variablesOfTable,obj.DB.variables);
            if any(~indV)
                error([mfilename ':: Cannot locate the variables; ' toString(obj.variablesOfTable(~indV))])
            end
            
            [ind,loc]   = ismember(obsOfTable,observations(obj.DB));
            if any(~ind)
                error([mfilename ':: Cannot locate observations; ' toString(obsOfTable(~ind))])
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
            dataAsCell = [{'Obs'}, obj.variablesOfTable;nb_double2cell(obsOfTable,'%.0f'), num2cell(dataT)];
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
                uimenu(selectM,'Label','Observations','Callback',{@obj.setObservationsGUI,'observations'});
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Variables','Callback',{@obj.reorderGUI,'variables'});
                uimenu(reorderM,'Label','Observations','Callback',{@obj.reorderGUI,'observations'});
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
        
            obj = nb_table_data.unstruct(s);
            
        end


    end
    
end
