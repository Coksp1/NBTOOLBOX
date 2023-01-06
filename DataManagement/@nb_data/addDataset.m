function obj = addDataset(obj,dataset,NameOfDataset,startObs,variables)
% Syntax:
%
% obj = addDataset(obj,dataset,NameOfDataset,startObs,variables)
%
% Description:
%
% Makes it possible to add one dataset to a existing nb_data
% object.
% 
% Caution : If more than one dataset is added to an object the link to the
%           data source is broken!
%
% Input:
% 
% - obj           : An object of class nb_data
% 
% - dataset       : One of the following:
%               
%                   > A string with the name of excel spreadsheet.
%                     (With or whitout extension)
%
%                   > A string with the name of a .mat file 
%                     (With or whitout extension)
%
%                   > A numerical matrix.
% 
% - NameOfDataset : Must be a string with the dataset name. If not
%                   given (or given as '') the default name
%                   Database<jj> is given. Where jj is the number 
%                   of added datasets of the object, including the
%                   dataset you add with this method.
%
%                   When fetching from FAME this input could be a 
%                   vintage tag. I.e. you could specify the vintage
%                   you want to fetch from FAME of the given 
%                   series. If the vintage tag does not exist it 
%                   will fetch the last vintage before the given 
%                   vintage tag.
%
% - startObs      : Number indicatating the observation number. 1 is
%                   default
% 
% - variables     : A cell array of strings with the names of the
%                   variables you want to add. Only needed when a
%                   numerical matrix of data, an tseries object, an 
%                   nb_math_ts object or when data from FAME is 
%                   added to the object.
%                    
%                   Must have the same size as the data you add. 
%                   (Second dimension)
%
%                   When fetching data from FAME this input decides 
%                   which variables to fetch.
% 
% Output:
% 
% - obj           : An nb_data object with the added dataset.
% 
% Examples:
%
% obj = nb_data();
% obj = obj.addDataset('excelFileName');
% obj = obj.addDataset('excelFileName2','A dataset name');
% obj = obj.addDataset('matFileName');
% 
% See also:
% nb_data, addDatasets, structure2Dataset
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        variables = {};
        if nargin < 4 
            startObs = 1;
            if nargin < 3
                NameOfDataset = '';
            end
        end

    end

    if isempty(obj)
        nameDim3 = 0;            
    else
        nameDim3 = size(obj.data,3);
    end
    
    if ~ischar(NameOfDataset)
        error([mfilename ':: NameOfDataset input must be a string with the name of the added dataset or the vintage tag to read from an fame database.'])
    end
    
    if ischar(variables)
        variables = cellstr(variables);
    end
    
    if ~isempty(startObs)
        if ischar(startObs)
            startObs = str2double(startObs);
            if isnan(startObs) 
                startObs = 1;
            end
        elseif isnumeric(startObs)
            if round(startObs) ~= startObs
                error('startObs must be a whole number');
            end
        end
    end
    
    % Get the properties of the new source
    [dataOfNewDataBase, variablesOfNewDataBase, startObsNewDataBase, endObsNewDataBase, userdata, localVariables] ...
        = nb_data.dataset2Properties(dataset,startObs,variables,NameOfDataset,obj.sorted);

    % Assign the userData and localVariables properties
    obj.userData       = userdata;
    obj.localVariables = localVariables;
    
    originalNameOfDataset = NameOfDataset;
    if isempty(NameOfDataset) && ischar(dataset)
        NameOfDataset = dataset;
    end
    
    if size(dataOfNewDataBase,2) ~= size(variablesOfNewDataBase,2)
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
                             int2str(size(variablesOfNewDataBase,2)) ') you are trying to add to the nb_data object; ' NameOfDataset '(dataset nr. ' int2str(obj.numberOfDatasets + 1) ' of the object)'])
        end
    end

    if ~isempty(obj.startObs)

        diffAtStart = startObsNewDataBase - obj.startObs;
        diffAtEnd   = endObsNewDataBase - obj.endObs;

        % Expand data if the start dates is not the
        % same for the new datasets and the rest
        if diffAtStart < 0

            dim1 = abs(diffAtStart);
            dim2 = size(obj.variables,2);
            dim3 = size(obj.data,3);

            obj.data     = [nan(dim1,dim2,dim3) ; obj.data];
            obj.startObs = startObsNewDataBase;

        elseif diffAtStart > 0

            verticalIndex     = size(dataOfNewDataBase,2);
            pages             = size(dataOfNewDataBase,3);
            dataOfNewDataBase = [nan(diffAtStart,verticalIndex,pages); dataOfNewDataBase]; 

        end

        % Expand data if the start dates is not the
        % same for the new datasets and the rest
        if diffAtEnd < 0

            verticalIndex     = size(dataOfNewDataBase,2);
            pages             = size(dataOfNewDataBase,3);
            dataOfNewDataBase = [dataOfNewDataBase; nan(abs(diffAtEnd),verticalIndex,pages)]; 

        else
            dim1 = diffAtEnd;
            dim2 = size(obj.variables,2);
            dim3 = size(obj.data,3);

            obj.data   = [obj.data ;nan(dim1,dim2,dim3)];  
            obj.endObs = endObsNewDataBase;
        end

    else

        obj.endObs   = endObsNewDataBase;
        obj.startObs = startObsNewDataBase;

    end
    
    if ~isempty(obj.variables)

        % Add nan for all variables in the dataset if it is not
        % included in the first place
        if size(obj.variables,2)~=size(variablesOfNewDataBase,2)

            [obj, dataOfNewDataBase] = updateData(obj,variablesOfNewDataBase,dataOfNewDataBase);

        elseif sum(strcmp(char(obj.variables),variablesOfNewDataBase)) ~= size(obj.variables,2)

            [obj, dataOfNewDataBase] = updateData(obj,variablesOfNewDataBase,dataOfNewDataBase);

        end

    else

        obj.variables = variablesOfNewDataBase;

    end

    % Add the data of the new dataset
    dim3 = size(dataOfNewDataBase,3);
    if ~isempty(obj.data)

        correctData = size(obj.data,2)-size(dataOfNewDataBase,2);
        if correctData~=0
            % Correct for some xlsread problems:
            dataOfNewDataBase = [dataOfNewDataBase nan(size(dataOfNewDataBase,1), correctData, dim3)];
        end

        obj.data(:,:,size(obj.data,3) + 1:size(obj.data,3) + dim3) = dataOfNewDataBase;

    else

        obj.data = dataOfNewDataBase;

    end


    % Collect database names
    if dim3 == 1

        if isempty(NameOfDataset)
            NameOfDataset = ['Database' int2str(nameDim3 + 1)];
        end

        obj.dataNames = [obj.dataNames NameOfDataset];
    else

        if isempty(NameOfDataset)
            NameOfDatasets = cell(1,dim3);
            for kk =1:dim3
                NameOfDatasets{kk} =  ['Database' int2str(nameDim3 + kk)];
            end

        else
            NameOfDatasets = cell(1,dim3);
            for kk =1:dim3
                NameOfDatasets{kk} =  [NameOfDataset '(' int2str(kk) ')'];
            end

        end

        obj.dataNames = [obj.dataNames NameOfDatasets];
    end
    
    % Check if the object is updatable (If it is a char a link 
    % could be made. And then it is assured to only consist of one 
    % page)
    test = obj.updateable;
    if ischar(dataset) && ~test
        
        % Add a link to the source
        source = dataset;
        if nb_contains(source,':\')
            
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
                    if ischar(originalNameOfDataset)
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
                
                newSubLink            = nb_createDefaultLink();
                newSubLink.source     = source;
                newSubLink.sourceType = sourceType;
                newSubLink.variables  = variablesOfNewDataBase;
                newSubLink.endDate    = endObsNewDataBase; % This is correct!
                newSubLink.startDate  = startObsNewDataBase; % This is correct!
                newSubLink.data       = obj.data;
                if foundWorksheetName == 1
                    newSubLink.sheet = originalNameOfDataset;
                end
                
                % Assign the link
                newLink.subLinks = newSubLink;
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
