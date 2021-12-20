function obj = addDataset(obj,dataset,nameOfDataset,startDate,locations,indicator,variables)
% Syntax:
%
% obj = addDataset(obj,dataset,nameOfDataset,startDate,locations,...
%                  indicator,variables)
%
% Description:
%
% Makes it possible to add a dataset to an existing nb_bd object
% 
% Caution : If more than one dataset is added to an object the link to the
%           data source is broken!
%
% Input:
% 
% - obj           : An object of class nb_bd
% 
% - dataset       : Either a string with the name of excel
%                   spreadsheet or a .mat file (no extension 
%                   needed), or a numerical matrix.
% 
% - nameOfDataset : Must be a string with the dataset name. If not
%                   given (or given as '') the default name
%                   Database<jj> is given. Where jj is the number 
%                   of added datasets of the object, including 
%                   dataset you add with this method.
% 
% - dates         : A cell array of string with the dates
%                   you want to add. Only needed when numerical 
%                   matrix of data is added to the  object. Must 
%                   have the same size as the data you add.
% 
% - variables     : A cell array of string with the names of the
%                   variables you want to add. Only needed when
%                   numerical matrix of data is added to the 
%                   object. Must have the same size as the data you
%                   add.
%                    
% Output:
% 
% - obj : The object itself with the added dataset.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 7
        variables = {};
        if nargin < 6 
            indicator = [];
            if nargin < 5
                locations = []; 
                if nargin < 4
                    startDate = '';
                    if nargin < 3
                        nameOfDataset = '';
                    end
                end
            end
        end
    end

    if isempty(obj)
        nameDim3 = 0;            
    else
        nameDim3 = obj.numberOfDatasets;
    end
    
    if ~ischar(nameOfDataset)
        error([mfilename ':: nameOfDataset input must be a string with the name of the added dataset or the vintage tag to read from an fame database.'])
    end
    
    if ischar(variables)
        variables = cellstr(variables);
    end
    
    % Get the properties of the new source
    [dataOfNewDataBase, variablesOfNewDataBase, startDateNewDataBase, endDateNewDataBase, freq, locationsOfNewDataBase, indicatorOfNewDataBase, userdata,localVariables] = ...
        nb_bd.dataset2Properties(dataset,startDate,variables,locations,indicator,nameOfDataset,obj.sorted);

    % Assign the userData and localVariables property
    obj.userData = userdata;
    try
        obj.localVariables = nb_structcat(obj.localVariables,localVariables);
    catch Err
        error([mfilename ':: Could not merge the local variables from the added dataset with the existing. ' Err.message])
    end
    
    originalnameOfDataset = nameOfDataset;
    if isempty(nameOfDataset) && ischar(dataset)
        nameOfDataset = dataset;
    end
    
    % Check that locations and variables match in the second dimension
    if mod(size(locationsOfNewDataBase,2),size(variablesOfNewDataBase,2)) ~= 0
        [~,loc] = ismember(variables,variablesOfNewDataBase);
        count   = zeros(size(variablesOfNewDataBase));
        for ii = 1:size(variablesOfNewDataBase,2)
            count(ii) = sum(loc==ii);
        end
        if any(count>1)
            vars = variablesOfNewDataBase(count>1);
            error([mfilename ':: The variables ' toString(vars) ' has been provided more times. Please remove the duplicates from the excel spreadsheet.'])
        else
            error([mfilename ':: The data has not the same size (' int2str(size(dataOfNewDataBase,2)) ') as the number of unique variables ('...
                             int2str(size(variablesOfNewDataBase,2)) ') you are trying to add to the nb_bd object; ' nameOfDataset '(dataset nr. ' int2str(obj.numberOfDatasets + 1) ' of the object)'])
        end
    end

    % Test if the added dataset has the same frequency as the rest
    % of the data of the object
    if ~isempty(obj.frequency)
        if freq ~= obj.frequency
            error([mfilename ':: the frequencies is not the same for the added dataset ;' nameOfDataset '(' nb_date.getFrequencyAsString(freq)  ') '...
                             'and the datasets of the object (' nb_date.getFrequencyAsString(obj.frequency) ')'])

        end
    else
        obj.frequency = freq;
    end

     if ~isempty(obj.startDate)

        diffAtStart = startDateNewDataBase - obj.startDate;
        diffAtEnd   = endDateNewDataBase - obj.endDate;

        % Expand data if the start dates is not the
        % same for the new datasets and the rest
        if diffAtStart < 0
            dim1 = abs(diffAtStart);
            dim2 = size(obj.variables,2);
            dim3 = size(obj.data,3);
            if obj.indicator
                added = zeros(dim1,dim2*dim3);
            else
                added = ones(dim1,dim2*dim3);
            end
            obj.locations = [added; obj.locations];
            obj.startDate = startDateNewDataBase;
        elseif diffAtStart > 0
            dim2 = size(locationsOfNewDataBase,2);
            if indicatorOfNewDataBase
                added = zeros(diffAtStart,dim2);
            else
                added = ones(diffAtStart,dim2);
            end
            locationsOfNewDataBase = [added; locationsOfNewDataBase]; 
        end

        % Expand data if the start dates is not the
        % same for the new datasets and the rest
        if diffAtEnd < 0
            dim2 = size(locationsOfNewDataBase,2);
            if indicatorOfNewDataBase
                added = zeros(abs(diffAtEnd),dim2);
            else
                added = ones(abs(diffAtEnd),dim2);
            end
            locationsOfNewDataBase = [locationsOfNewDataBase; added]; 
        elseif diffAtEnd > 0
            dim2 = size(obj.variables,2);
            dim3 = obj.numberOfDatasets;
            if obj.indicator
                added = zeros(diffAtEnd,dim2*dim3);
            else
                added = ones(diffAtEnd,dim2*dim3);
            end
            obj.locations = [obj.locations; added];  
            obj.endDate   = endDateNewDataBase;
        end

    else
        obj.endDate   = nb_date.toDate(endDateNewDataBase,obj.frequency);
        obj.startDate = nb_date.toDate(startDateNewDataBase,obj.frequency);
    end
    

    if ~isempty(obj.variables)

        % Add nan for all variables in the dataset if it is not
        % included in the first place
        if size(obj.variables,2)~=size(variablesOfNewDataBase,2)
            [obj, locationsOfNewDataBase] = updateLocations(obj,variablesOfNewDataBase,dataOfNewDataBase);
            indicatorOfNewDataBase = 1; % Indicator set to 1 in the funtion. Should be optimal as adding dataset 
                                        % (to an existing one) produces many nans..
        elseif ~all(ismember(obj.variables,variablesOfNewDataBase))
            [obj, locationsOfNewDataBase] = updateLocations(obj,variablesOfNewDataBase,dataOfNewDataBase);
            indicatorOfNewDataBase = 1;
        end

    else
        obj.variables = variablesOfNewDataBase;
    end

    % Add the data of the new dataset. Data is stored in a full column of
    % doubles
    dim3       = size(dataOfNewDataBase,3);
    newDataVec = dataOfNewDataBase(:);
    newData    = dataOfNewDataBase(~isnan(newDataVec)); 
    if ~isempty(obj.data)
        obj.data = [obj.data;newData(:)];
    else
        obj.data = newData(:);
    end

    
    % Add locations and indicator properties
    if ~isempty(obj.indicator)
        % Is set to 1 in nb_bd.updateLocations so need to check if we
        % should set to 0. Also, merge locations
        
        % Number of datapoints:
        fullLocations = [obj.locations,locationsOfNewDataBase];
        numOnes       = full(sum(fullLocations,'all')); 
        numElements   = numel(fullLocations); 
        if numOnes > ( 0.5 * numElements )
            obj.locations = ~fullLocations;
            obj.indicator = 0;
        else
            obj.locations = fullLocations;
        end
    else
        obj.locations = locationsOfNewDataBase;
        obj.indicator = indicatorOfNewDataBase;   
    end
    
    % Collect database names
    if dim3 == 1
        if isempty(nameOfDataset)
            nameOfDataset = ['Database' int2str(nameDim3 + 1)];
        end
        obj.dataNames = [obj.dataNames nameOfDataset];
    else

        if isempty(nameOfDataset)
            nameOfDatasets = cell(1,dim3);
            for kk =1:dim3
                nameOfDatasets{kk} =  ['Database' int2str(nameDim3 + kk)];
            end
        else
            nameOfDatasets = cell(1,dim3);
            for kk =1:dim3
                nameOfDatasets{kk} =  [nameOfDataset '(' int2str(kk) ')'];
            end
        end
        obj.dataNames = [obj.dataNames nameOfDatasets];
    end

    % Check if the object is updatable (If it is a char a link 
    % could be made. And then it is assured to only consist of one 
    % page)
    test = obj.updateable;
    if ischar(dataset) && ~test
        
        % Add a link to the source
        source     = dataset;
        createLink = 0;
        
        
        if nb_contains(source,'.db')
            
            % If vintage is given we don't have a updatable source
            sourceType = 'db';
            if ~nb_contains(source,':\')
                createLink = 1;
            else
                shortcuts = nb_fameShortcuts();
                found     = find(strcmpi(source,shortcuts),1);
                if found
                    createLink = 1;
                end
            end

            if createLink == 1

                % When the full path name is given we can store it as 
                % a link to the given FAME database
                newLink            = nb_createDefaultLink();
                newLink.source     = source;
                newLink.sourceType = sourceType;
                newLink.variables  = variablesOfNewDataBase;
                newLink.startDate  = startDateNewDataBase;
                newLink.data       = obj.data(:,:,obj.numberOfDatasets);
                
                if ~isnan(str2double(nameOfDataset))  
                    newLink.vintage = nameOfDataset; % A vintage is given
                end
                
                % Assign the link
                newLink.subLinks = newLink;
                obj.links        = newLink;
                obj.updateable   = 1;

            end
            
        elseif nb_contains(source,':\')
            
            foundWorksheetName = 0;
            c                  = strfind(source,'.'); 
            if isempty(c)
                
                if exist([source '.xlsx'],'file') == 2
                    ext = 'xlsx';
                else
                    if exist([source '.mat'],'file') == 2
                        ext = 'mat';
                    else
                        if exist([source '.xls'],'file') == 2
                            ext = 'xls';
                        else
                            if exist([source '.xlsm'],'file') == 2
                                ext = 'xlsm';
                            else
                                if exist([source '.csv'],'file') == 2
                                    ext = 'csv';
                                end
                            end
                        end
                    end
                end
                
            else
                ext = source(c(1) + 1:end);
            end
                
            switch lower(ext)

                case {'xlsx','xls','xlsm','csv'}

                    if ischar(originalnameOfDataset)
                        foundWorksheetName = 1;
                    end
                    createLink = 1;
                    sourceType = 'xls';

                case 'mat'

                    createLink = 1;
                    sourceType = 'mat';

                otherwise
                    error([mfilename ':: Unsupported extension ' ext])

            end
            
            if createLink
                
                newLink            = nb_createDefaultLink();
                newLink.source     = source;
                newLink.sourceType = sourceType;
                newLink.variables  = variablesOfNewDataBase;
                newLink.startDate  = startDateNewDataBase;
                newLink.endDate    = endDateNewDataBase;
                newLink.data       = obj.data(:,:,obj.numberOfDatasets);
                if foundWorksheetName == 1
                    newLink.sheet = originalnameOfDataset;
                end
                
                % Assign the linkobj.
                newLink.subLinks = newLink;
                obj.links        = newLink;
                obj.updateable   = 1;
                
            end
            
        end
        
        
    end
    
    % Break link if more pages! 
    if test
        obj.links      = struct([]);
        obj.updateable = 0;
    end
    
end
