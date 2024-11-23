classdef nb_bd < nb_dataSource
% Description:
%
% A class for storing vintage / business-day data or simply time-series 
% with a large share of missing values.
%    
% Constructor:      
%
%   obj = nb_bd(datasets,nameOfDatasets,startDate,variables)
%   obj = nb_bd(datasets,nameOfDatasets,startDate,variables,sorted)
% 
%   Input:
% 
%   - datasets: 
%         
%      Input can be one of the data types listed below:       
%  
%      - xls(x) : A name of the excel spreadsheet to import. (With 
%                 or without extension.). As a string.
%
%                 Caution : If you read a specific worksheet, and
%                             want the object to be updateable
%                             you must provide the extension.
% 
%      - mat    : Name(s) of the .mat file(s) to import. (With or  
%                 without extension.) As a string. This .mat 
%                 file must store a struct where each field stores 
%                 the data of a variable. The data stored at each 
%                 field must be doubles with same size. The only 
%                 exception is that you must include a field called
%                 'dates', storing a cellstr with the dates of the
%                 data. (This cellstr must have the same size as 
%                 the provided data (size of the first dimension)).
%
%                 Caution : The data stored as seperate field could
%                           have more pages (size of the third 
%                           dimension could be lager then 1). Again
%                           All the data of the variables must be
%                           of the same size.
% 
%      - double : As a double matrix. Each page of the matrix will 
%                 be added as separate datasets.  
% 
%      - struct : As a structure of double matrices. Each field is 
%                 added as a separate datasets.
%         
%      You can also give a cell array consisting of one or a 
%      combination of the data types mentioned above. Each cell 
%      will be added as a new dataset. 
%  
%      Extra: Use the method structure2nb_bd function to add all 
%             the fields of the structure as variables in an 
%             nb_bd object. (If each field has more page then 1, 
%             then each page will be a new datasets). See the 
%             method structure2nb_bd for more on the supported 
%             format of the structure you can provide as input.
%         
%   - nameOfDatasets :
%
%      Input will depend on the data type provided to the datasets 
%      input:       
%  
%      - xls(x) : A string with the wanted dataset name. Default 
%                 is the excel file name. If the provided string
%                 is a sheet of the read spreadsheet that specific
%                 worksheet will be read.
% 
%      - mat    : A string with the wanted dataset name. Default 
%                 is the .mat file name.
% 
%      - double : A string with the wanted dataset name. Default 
%                 is 'Dataset1'.  
%
%                 Caution: When you given double matrices which 
%                          has more pages then one, either 
%                          directly or through a struct. Each of 
%                          the pages will be added as a dataset. 
%                          The name of this datasets will, if the 
%                          input nameOfDatasets has the same size 
%                          as the input datasets, get the name 
%                          nameOfDatasets{jj}<jj>, where jj is 
%                          the page number, or else get the name 
%                          'Database<jj>'.
% 
%      - struct : This input has no consequence. The dataset 
%                 names will be given by the fieldnames.
%
%      - A cell array of the listed types above:
% 
%        If you give a cell array to the datasets input, this input 
%        must be a cell array of strings. If you give a cell array 
%        which doesn't have the same size as the cell array given 
%        to the datasets input, the datasets which is left gets the 
%        name 'Database<jj>', where <jj> stands for this added 
%        datasets number.
% 
%        If you give an empty cell array, i.e. {} all the datasets 
%        get the names; 'Database<jj>', where <jj> stands for the 
%        added datasets number. Except when the datasets input are 
%        given by a cellstr with the excel file names or .mat file  
%        names, then the default dataset names will be set to the 
%        same cellstr. Or if some elements of the cell is a struct, 
%        then the datasets provided through the struct will get
%        their fieldnames as the dataset names. 
%         
%   - dates :    
%         
%      A cell array of the type names of the data, as strings. Only
%      needed when you give a double or a struct of doubles as the 
%      datasets input. The number of dates must be the same as the 
%      size of the data (1- dimension).
%         
%   - variables :
%         
%      A cell array of the variable names of the data, as strings. 
%      Only needed when you give a double or a struct of doubles as 
%      the datasets input. The number of variables must be the same 
%      as the size of the data (2- dimension).
%
%   - sorted    : true or false. Default is true.
%
%   Output:
% 
%   - obj      : An object of class nb_bd.
% 
%   Examples:
% 
%   - xls(x):
%             
%      One excel spreadsheet
%         
%      obj = nb_bd('test1')
%         
%      More excel spreadsheets
%            
%      obj = nb_bd({'test1','test2',...})
%              
%   - mat:
%         
%      One .mat file:
%         
%      obj = nb_bd('test1')
%         
%      More .mat files:
%         
%      obj = nb_bd({'test1','test2',...})
%         
%      same as
%         
%      obj = nb_bd({'test1','test2',...},{'test1','test2',...})
%              
%   - double matrix:
%         
%      One matrix
%         
%      obj = nb_bd(double1,'','2000Q1',{'Var1','Var2',...})
%         
%      obj = nb_bd(double1,'test1','2000Q1',{'Var1','Var2',...})
%         
% See also: 
% nb_graph_bd, nb_ts, nb_graph_ts
% 
% Written by Per Bjarne Bye  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

     properties (SetAccess=protected,Dependent=true)
        
        % Number of observation of the data stored in the object. As a 
        % double.
        numberOfObservations    
        
    end

    properties
        
        % The end date of the data. Given as an object which is of a 
        % subclass of the nb_date class. Either: nb_day, nb_week, nb_month, 
        % nb_quarter, nb_semiAnnual or nb_year.
        endDate                 = nb_date;       
        
        % Frequency of data: 
        % 1   : yearly (also used for integers)
        % 2   : semiannually 
        % 4   : quarterly
        % 12  : monthly
        % 52  : weekly
        % 365 : daily
        frequency               = [];            
        
        % The start date of the data. Given as an object which is of a 
        % subclass of the nb_date class. Either: nb_day, nb_week, nb_month, 
        % nb_quarter, nb_semiAnnual or nb_year.
        startDate               = nb_date;
        
        % Sparse logical keeping track of where we have observations or
        % not. NaN is counted as a missing observation.
        locations               = [];
        
        % A boolean indicating if either (1) the locations where we do have
        % an observation should be saved as 1 or (0) the locations where we
        % do not have an observation should be saved as 1. This affects the
        % memory required to save the sparse <locations> double. By default
        % this will be set to the "best" option, that is the option that
        % requires the least memory.
        % indicator = 1 : observation = 1, missing value = 0
        % Indicator = 0 : observation = 0, missing value = 1
        indicator               = [];
        
        % A boolean indicating if we should (1) (default) ignore NaNs when 
        % doing calculations on the dataset or (0) take NaNs into account 
        % when doing these calculations. Note that taking NaNs into account 
        % require the dataset to be expanded prior to the operation and
        % will consequently take more time. Also, this will behave like a 
        % nb_ts calculation.
        ignorenan               = 1;
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function obj = nb_bd(datasets,nameOfDatasets,startDate,variables,locations,indicator,sorted,ignorenan)
        % Constructor      
            if nargin < 8 
                ignorenan = 1;
                if nargin < 7
                    sorted = true;
                    if nargin < 6
                        indicator = [];
                        if nargin < 5 
                            locations = [];
                            if nargin < 4
                                variables = {};
                                if nargin < 3
                                    startDate = '';
                                    if nargin < 2
                                        nameOfDatasets = {};
                                        if nargin < 1
                                           datasets = {}; 
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            obj           = obj@nb_dataSource;
            obj.sorted    = sorted;
            obj.ignorenan = ignorenan;
            
            if ~isempty(datasets)
                
                if isnumeric(datasets) || islogical(datasets) || isa(datasets,'nb_distribution')
                    
                    if isempty(nameOfDatasets)
                        nameOfDatasets = '';
                    end
                   
                    try
                        obj = addDataset(obj,datasets,nameOfDatasets,startDate,locations,indicator,variables);
                    catch Err
                        
                        if ~iscellstr(nameOfDatasets) %#ok<ISCLSTR>
                            rethrow(Err);
                        end
                        
                        if size(datasets,3) == length(nameOfDatasets)  
                            obj           = addDataset(obj,datasets,'',startDate,locations,indicator,variables);
                            obj.dataNames = nb_rowVector(nameOfDatasets);
                        else
                            rethrow(Err);
                        end
                                 
                    end
                    
                elseif ischar(datasets) || isa(datasets,'dyn_ts') || isa(datasets,'tseries') || isa(datasets,'ts') || isa(datasets,'nb_math_ts')
                    
                    if isempty(nameOfDatasets)
                        nameOfDatasets = '';
                    end
                    
                    obj = addDataset(obj,datasets,nameOfDatasets,startDate,variables);
                    
                elseif isstruct(datasets)
                    
                    datasets = {datasets};
                    
                    obj = addDatasets(obj,datasets,{},startDate,variables);
                    
                elseif isa(datasets,'DataPackage.TS')
                    
                    obj = nb_bd(datasets.getData(),cell(datasets.getDataNames())',char(datasets.getStartDateAsString()),cell(datasets.getVariables())',sorted);
                    
                else
                    try
                        obj = addDatasets(obj,datasets,nameOfDatasets,startDate,variables);
                    catch Err
                        
                        if iscell(datasets)
                            rethrow(Err)
                        else
                            
                            if strcmp(Err.identifier,'nb_bd:addDatasets:inputMustBeACell')
                                error([mfilename ':: An object of class ' class(datasets) ' is not supported as the datasets input.'])
                            else
                                rethrow(Err)
                            end
                            
                        end
                        
                    end
                
                end
                
            end
                
        end
        
        function value = get.numberOfObservations(obj)
            value = size(obj.locations,1);
        end
        
    end
        
    %======================================================================
    % Methods not saved in seperate files
    %======================================================================
    methods (Access=public,Hidden=true)
        
        function [isOK,errorIdentifier] = checkConformity(obj,DB)
        % Checks if two nb_bd objects have the same dimensions and
        % variables

            isOK = 0;

            if obj.startDate ~= DB.startDate || obj.endDate ~= DB.endDate
                errorIdentifier = 1;
            else
                if obj.numberOfVariables ~= DB.numberOfVariables
                    errorIdentifier = 2;
                else
                    if sum(strcmp(char(obj.variables),DB.variables)) ~= obj.numberOfVariables
                        errorIdentifier = 3;
                    else
                        if DB.numberOfDatasets ~= obj.numberOfDatasets
                            errorIdentifier = 4;                           
                        else
                            errorIdentifier = [];
                            isOK            = 1;
                        end
                    end
                end
            end

        end
        
        function n = numArgumentsFromSubscript(obj,~,~)
            n = numel(obj);
        end
        
        function ind = end(obj,k,~)
        
            switch k
                
                case 1
                    ind = obj.numberOfObservations;
                case 2
                    ind = obj.numberOfVariables;
                case 3
                    ind = obj.numberOfDatasets;
            end
            
        end
        
        varargout = interpretDateInput(varargin)
        
    end
    
    %{
    =======================================================================
    Protected methods of this class
    =======================================================================
    %}
    methods (Access=protected)
        
        function [obj,locationsNew] = updateLocations(obj,variablesOfNewDataBase,dataOfNewDataBase)
        % Update obj.variables, when variables are different for the existing 
        % and added dataset to the nb_bd object. Pads location in the
        % second dimension.
        
            % Find the variables not contained in both datasets
            newVariables = nb_bd.getDiff(variablesOfNewDataBase,obj.variables);
            if obj.sorted
                obj.variables = sort([obj.variables, newVariables]);
            else
                obj.variables = [obj.variables, newVariables];
            end
            
            fullData = getFullRep(obj);
            
            % New variables found in the new dataset
            indexNewVariables       = nb_findIndex(newVariables,obj.variables);
            indexNNV                = ~indexNewVariables;
            transData               = nan(size(fullData,1),size(fullData,2) + size(newVariables,2),size(fullData,3));
            transData(:,indexNNV,:) = fullData;
            
            locationsOld = ~isnan(transData);
            if size(locationsOld,3) > 1
                locationsOld = reshape(locationsOld,[size(locationsOld,1),size(locationsOld,2)*size(locationsOld,3)]);
            end
            obj.locations = sparse(locationsOld);
            obj.indicator = 1;

            % Variables not found in the new dataset
            [ind,loc]          = ismember(variablesOfNewDataBase,obj.variables);
            loc                = loc(ind);
            transData          = nan(size(dataOfNewDataBase,1),size(obj.locations,2) * size(dataOfNewDataBase,3));
            transData(:,loc,:) = dataOfNewDataBase;
            
            locationsNew = ~isnan(transData);
            if size(locationsNew,3) > 1
                locationsNew = reshape(locationsNew,[size(locationsNew,1),size(locationsNew,2)*size(locationsNew,3)]);
            end
            locationsNew = sparse(locationsNew);

        end
        
        function [startDateWin,endDateWin,variablesWin,startInd,endInd,variablesInd,pages] = getWindow(obj,startDateWin,endDateWin,variablesWin,pages)


            % Which dates to keep
            if ~isempty(startDateWin)

                startDateWin = nb_date.toDate(startDateWin,obj.frequency);
                startInd = (startDateWin - obj.startDate) + 1;
                if startInd < 1 || startInd > obj.numberOfObservations

                    error([mfilename ':: beginning of window (''' startDateWin.toString ''') starts before the start date (''' obj.startDate.toString() ''') '...
                                     'or starts after the end date (''' obj.endDate.toString ''') of the data '])

                end

            else
                startInd     = 1;
                startDateWin = obj.startDate;
            end

            if ~isempty(endDateWin)

                endDateWin   = nb_date.toDate(endDateWin,  obj.frequency);
                endInd = (endDateWin - obj.startDate) + 1;
                if endInd < 1 || endInd > obj.numberOfObservations

                    error([mfilename ':: end of window (''' endDateWin.toString ''') ends after the end date (''' obj.endDate.toString ''') or '...
                                     'ends before the start date (''' obj.startDate.toString() ''') of the data '])

                end

            else
                endInd     = obj.numberOfObservations;
                endDateWin = obj.endDate;
            end

            % Remove all other variables not given in the cellstr variables
            if ~isempty(variablesWin)

                variablesWin = cellstr(variablesWin);
                variablesInd = zeros(1,max(size(obj.variables)));
                for ii = 1:max(size(variablesWin))
                    var_id = strcmp(variablesWin{ii},obj.variables);
                    variablesInd = variablesInd + var_id;
                    if sum(var_id)==0
                        warning('nb_ts:window:VariableNotFound',[mfilename ':: Variable ''' variablesWin{ii} ''' not found.']) 
                    end
                end

                variablesInd = logical(variablesInd);

            else

                variablesWin = obj.variables;
                variablesInd = true(1,size(obj.variables,2)); % To ensure that we keep all variables

            end

            % Which pages to keep
            if isempty(pages)
                pages = 1:obj.numberOfDatasets;
            else
                if isnumeric(pages)
                    m = max(pages);
                    if m > obj.numberOfDatasets
                        error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to reach the dataset ' int2str(m) ', which is not possible.'])
                    end
                elseif ischar(pages)
                    pages = strcmp(pages,obj.dataNames);
                else
                    pages = nb_bd.locateVariables(pages,obj.dataNames);
                end
            end

        end

        function obj = evalStatOperator(obj,func,outputType,dimension,extraInp) 
            
            oldObj = obj;
            
            fullData = getFullRep(obj);
            
            if ~obj.ignorenan && ~isa(func,'max') %notHandleNaN
                
                switch lower(outputType)
                    case 'nb_bd'
                        
                        values = func(fullData,extraInp{:},dimension);
                        switch dimension
                            case 1
                                values = values(ones(1,obj.numberOfObservations),:,:);
                            case 2
                                values = values(:,ones(1,obj.numberOfVariables),:,:);
                            case 3
                                values = values(:,:,ones(1,obj.numberOfDatasets));
                        end
                        [loc,ind,data] = nb_bd.getLocInd(values);
                        obj.locations  = loc;
                        obj.indicator  = ind;
                        obj.data       = data;
                        
                    case 'double'
                        
                        values = func(fullData,extraInp{:},dimension);
                        obj    = values;
                        
                    case 'nb_cs'

                        switch dimension
                            case 1   
                            otherwise  
                                error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''nb_cs''.'])     
                        end
                        values             = func(fullData,extraInp{:},dimension);
                        locVars            = obj.localVariables;
                        obj                = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);
                        obj.localVariables = locVars;
                        
                end
                return
                
            end
            
            % I cannot vectorize here because the function mean made by
            % matlab does not handle nan values as wanted.
            switch lower(outputType)

                case 'nb_bd'

                    switch dimension

                        case 1

                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfDatasets
                                    isNotNan = ~isnan(fullData(:,ii,jj));
                                    if any(isNotNan)
                                        inp                      = [{fullData(isNotNan,ii,jj)},extraInp];
                                        fullData(isNotNan,ii,jj) = func(inp{:});
                                    end
                                end
                            end

                        case 2

                            for ii = 1:obj.numberOfDatasets
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(fullData(jj,:,ii));
                                    if any(isNotNan)
                                        inp                      = [{fullData(jj,isNotNan,ii)},extraInp];
                                        fullData(jj,isNotNan,ii) = func(inp{:});
                                    end
                                end
                            end

                        case 3

                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(fullData(jj,ii,:));
                                    if any(isNotNan)
                                        inp                      = [{fullData(jj,ii,isNotNan)},extraInp,{3}];
                                        fullData(jj,ii,isNotNan) = func(inp{:});
                                    end
                                end
                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) '.'])

                    end
                    
                    [loc,ind,dataOut] = nb_bd.getLocInd(fullData);
                    obj.locations     = loc;
                    obj.indicator     = ind;
                    obj.data          = dataOut;

                case 'double'

                    switch dimension

                        case 1

                            values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfDatasets
                                    isNotNan = ~isnan(fullData(:,ii,jj));
                                    if any(isNotNan)
                                        inp             = [{fullData(isNotNan,ii,jj)},extraInp];
                                        values(1,ii,jj) = func(inp{:});
                                    end
                                end
                            end

                        case 2

                            values = nan(obj.numberOfObservations,1,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfDatasets
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(fullData(jj,:,ii));
                                    if any(isNotNan)
                                        inp             = [{fullData(jj,isNotNan,ii)},extraInp];
                                        values(jj,1,ii) = func(inp{:});
                                    end
                                end
                            end

                        case 3

                            values = nan(obj.numberOfObservations,obj.numberOfVariables,1);
                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(fullData(jj,ii,:));
                                    if any(isNotNan)
                                        inp             = [{fullData(jj,ii,isNotNan)},extraInp,{3}];
                                        values(jj,ii,1) = func(inp{:});
                                    end
                                end
                            end

                        otherwise
                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) '.'])   
                    end
                    
                    obj = values;
                                            
                case 'nb_cs'

                    switch dimension
                        case 1   
                        otherwise  
                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''nb_cs''.'])     
                    end

                    values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                    for ii = 1:obj.numberOfVariables
                        for jj = 1:obj.numberOfDatasets
                            isNotNan = ~isnan(fullData(:,ii,jj));
                            if any(isNotNan)
                                inp             = [{fullData(isNotNan,ii,jj)},extraInp];
                                values(1,ii,jj) = func(inp{:});
                            end
                        end
                    end
                    locVars            = obj.localVariables;
                    obj                = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);
                    obj.localVariables = locVars;
                    
                otherwise

                    error([mfilename ':: Non supported output type; ' outputType])

            end
            
            if oldObj.isUpdateable() 

                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                if strcmpi(outputType,'nb_bd')

                    obj = obj.addOperation(func,[extraInp, {outputType,dimension}]);

                elseif strcmpi(outputType,'nb_cs')

                    oldObj = oldObj.addOperation(func,[extraInp,{outputType,dimension}]);
                    linksT = oldObj.links;
                    obj    = obj.setLinks(linksT);

                end

            end
            
        end
        
        varargout = getFullRep(varargin);
        varargout = getStrippedRep(varargin);
        
    end
    
    %==============================================================
    % Protected static methods of this class
    %==============================================================
    methods (Static=true, Access=protected, Hidden=true)
         
        function [data, variables, startDate, endDate, frequency, locations, indicator, userData,localVariables] = dataset2Properties(dataset,startDate,var,locations,indicator,vintage,sorted)
        % Load properties (data) from .xls file, .mat file

            if nargin < 4
                vintage = '';
                if nargin < 3
                    var = {};
                end
            end
            userData       = '';
            localVariables = [];
            width          = size(dataset,2);
            pages          = size(dataset,3);

            if isnumeric(dataset) || islogical(dataset) || isa(dataset,'nb_distribution')

                if isempty(startDate)
                    warning(['Start date of data is not given, ''1994Q1'' is default. '...
                             '(This is only important if the data is given from a .mat file or as a double matrix)']) %
                    startDate = '1994Q1';
                end

                if isempty(dataset)

                    % Return these values to get a good error message
                    data      = [];
                    variables = var;
                    startDate = '';
                    endDate   = '';
                    frequency = [];

                else
                    tempData = dataset;
                    
                    if isempty(locations)
                    % No locations assigned in the constructor. Find from 
                    % dataset (here, we know that its not empty).
                        [tempLoc,indicator,~] = nb_bd.getLocInd(tempData); 
                    else
                        tempLoc = locations;
                    end
                    notSortedVar = strtrim(cellstr(var));

                    if size(notSortedVar,2)==1
                        notSortedVar =  notSortedVar'; 
                    end

                    variables = nb_bd.removeDuplicates(sort(notSortedVar));                
                    if size(variables,2) == size(dataset,2) 

                        if sorted
                            % Reallocate given that the variables is sorted
                            [~,loc]   = ismember(variables,notSortedVar);
                            % Need to convert to a full matrix to do N-dim
                            % indexing
                            fullLoc   = full(tempLoc);
                            len       = size(fullLoc,1);
                            fullLoc   = reshape(fullLoc,[len,width,pages]);
                            fullLoc   = fullLoc(:,loc,:);
                            data      = tempData(:,loc,:);
                            % Back to 2D transform
                            if pages > 1
                                fullLoc = reshape(fullLoc,[len,width*pages]);
                            end
                            locations = sparse(fullLoc);
                        else
                            locations = sparse(tempLoc); 
                            variables = notSortedVar;
                            data      = tempData;
                        end
                        
                        % Check that no variables are empty
                        ind = ~cellfun('isempty',variables);
                        if ~any(ind)
                            variables = variables(ind);
                            fullLoc   = full(locations);
                            locations = fullLoc(:,ind,:);
                            locations = sparse(locations);
                        end
                    else % Just to make it to the error message in addDataset method instead
                        % Do nothing.
                        % This is the case if the user passes a vector of
                        % data and the locations of where to locate the
                        % data.
                        data = dataset;
                    end

                    if ischar(startDate)
                        [startDate,frequency] = nb_date.date2freq(startDate);
                    elseif isa(startDate,'nb_date')
                        frequency = startDate.frequency;   
                    elseif isnumeric(startDate)
                        startDate = nb_year(startDate);
                        frequency = 1;
                    else 
                        error([mfilename ':: the ''startDate'' input must either be a string or an integer.'])
                    end

                    periods = size(locations,1);
                    endDate = startDate + periods - 1;

                end

            elseif ischar(dataset)

                % Decide which type of file we are trying to load
                dotIndex = strfind(dataset,'.');
                if ~isempty(dotIndex)
                    type    = dataset(dotIndex(end) + 1:end);
                    dataset = dataset(1:dotIndex(end)-1);
                else
                    if exist([dataset '.xlsx'],'file') == 2
                        type = 'xlsx';
                    else
                        if exist([dataset '.mat'],'file') == 2
                            type = 'mat';
                        else
                            if exist([dataset '.xlsm'],'file') == 2
                                type = 'xlsm';
                            else
                                if exist([dataset '.csv'],'file') == 2
                                    type = 'csv';
                                else
                                    if exist([dataset '.xls'],'file') == 2
                                        type = 'xls';
                                    else
                                        type = 'unknown';
                                    end
                                end
                            end
                        end
                    end
                end

                switch lower(type)

                    case 'xlsx'

                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency,locations,indicator] = nb_bd.xls2Properties([dataset '.xlsx'],sheet,sorted);
                        
                    case 'xlsm'
                        
                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency,locations,indicator] = nb_bd.xls2Properties([dataset '.xlsm'],sheet,sorted);

                    case 'csv'
                        
                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency] = nb_bd.xls2Properties([dataset '.csv'],sheet,sorted);
                        
                    case 'mat'

                        temp = load(dataset);
                        [data, variables, startDate, endDate, frequency, locations, indicator, userData,localVariables] = nb_bd.structure2PropertiesNew(temp,'',sorted); % Here we assume that the startDate are the same for all databases

                    case 'xls'

                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency] = nb_bd.xls2Properties(dataset,sheet,sorted);
                        
                    otherwise
                        error([mfilename ':: Cannot read the provided file format; ' type])

                end
 
            else
                error([mfilename ':: Dataset is not a string with name of mat file or xls file or a double matrix with data (variables must then be given).'])
            end
        end
         
        function [data, variables, startDate, endDate, frequency, userData,localVariables] = structure2Properties(structure,startDate,sorted)
        % Load properties from a structure of double vectors

            if nargin < 2
                startDate = '';                             
            end
        
            if isfield(structure,'variables')
                [data, variables, startDate, endDate, frequency, userData,localVariables] = nb_bd.structure2PropertiesNew(structure,startDate,sorted);
                return
            end

            variables = fieldnames(structure)';

            if isempty(startDate)

                % Load the start date from the structure
                found = find(strcmpi('startDate',variables),1);
                if isempty(found)
                    error([mfilename ':: When loading data from a structure or a .mat file the structure or mat file must contain a field ''startDate'', '...
                          'which must consist of a string with the start date of the loaded data.'])
                end
                startDate = structure.(variables{found});

            else

                found = 0;

            end
            
            if ~isempty(found)
                variables = [variables(1:found-1) variables(found+1:end)];
            end
            
            if ischar(startDate)

                [startDate, frequency] = nb_date.date2freq(startDate);

            elseif isa(startDate,'nb_date')

                frequency = startDate.frequency;

            elseif isnumeric(startDate) 

                % Make it possible to use integer instead of dates
                startDate = nb_year(startDate);
                frequency = 1;

            else 
                error([mfilename ':: the ''startDate'' input must either be a string or an integer.'])
            end

            foundUD  = find(strcmpi('userData',variables),1);
            userData = '';
            if ~isempty(foundUD)
                userData  = structure.(variables{foundUD});
                variables = [variables(1:foundUD-1) variables(foundUD+1:end)];
            end
            
            foundLV        = find(strcmpi('localVariables',variables),1);
            localVariables = [];
            if ~isempty(foundLV)
                localVariables = structure.(variables{foundLV});
                variables      = [variables(1:foundLV-1) variables(foundLV+1:end)];
            end
            
            foundC  = find(strcmpi('class',variables),1);
            if ~isempty(foundC)
                variables = [variables(1:foundC-1) variables(foundC+1:end)];
            end
            
            foundS  = find(strcmpi('sorted',variables),1);
            if ~isempty(foundS)
                variables = [variables(1:foundS-1) variables(foundS+1:end)];
            end
            
            % Load the variables from the structure
            variablesTemp = variables;
            [r,c,p]       = size(double(structure.(variablesTemp{1})));
            if r == 1
                r = c;
            end
            data = nan(r,length(variables),p);
            for j = 1:size(variablesTemp,2)
                data(:,j,:) = double(structure.(variablesTemp{j}));
            end

            if isa(data,'ts')
               data.varnames = variablesTemp;
            end
            
            % Get the end date
            periods = size(data,1);
            endDate = startDate + periods - 1;
            
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_ts.locateVariables(variables,variablesTemp);  
            if sorted
                data = data(:,ind,:); 
            else
                variables = variablesTemp;
            end

        end        
        
     
        function [data, variables, startDate, endDate, frequency, locations, indicator, userData,localVariables] = structure2PropertiesNew(structure,startDate,sorted)
        % Load properties from a structure of double vectors
    
            variables = structure.variables;

            if nargin < 2
                startDate = '';
            end

            if isempty(startDate)
                startDate = structure.startDate;
            end
            
            if ischar(startDate)
                [startDate, frequency] = nb_date.date2freq(startDate);
            elseif isa(startDate,'nb_date')
                frequency = startDate.frequency;
            elseif isnumeric(startDate) 
                startDate = nb_year(startDate);% Make it possible to use integer instead of dates
                frequency = 1;
            else 
                error([mfilename ':: the ''startDate'' input must either be a string or an integer.'])
            end

            userData       = structure.userData;
            localVariables = structure.localVariables;
           
            % Load the variables from the structure
            variablesTemp = variables;
            [r,c,p]       = size(structure.Var1);
            if r == 1
                r = c;
            end
            tempData = nan(r,length(variables),p);
            for j = 1:size(variablesTemp,2)
                tempData(:,j,:) = structure.(['Var' int2str(j)]);
            end
            
            if isa(tempData,'ts')
               tempData.varnames = variablesTemp;
            end
            
            % Get the end date
            periods = size(tempData,1);
            endDate = startDate + periods - 1;
            
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_bd.locateVariables(variables,variablesTemp);  
            if sorted
                tempData = tempData(:,ind,:); 
            else
                variables = variablesTemp;
            end
            
            [locations,indicator,data,~] = nb_bd.getLocInd(tempData);

        end
        
        function [data, variables, startDate, endDate, frequency,locations,indicator] = xls2Properties(xls,sheet,sorted)
        % Load from excel spreadsheet to properties of nb_bd

        
            c   = nb_xlsread(xls,sheet);
            obj = nb_cell2obj(c,true,sorted);
            if ~isa(obj,'nb_bd')
                error([mfilename ':: Cannot convert the data of the file ' xls ' to time-series.'])
            end
            data      = obj.data;
            variables = obj.variables;
            startDate = obj.startDate;
            endDate   = obj.endDate;
            frequency = obj.startDate.frequency;
            locations = obj.locations;
            indicator = obj.indicator;
            
       
        end
        
    end
    
    %==============================================================
    % Static methods of this class
    %==============================================================
    methods (Static=true)
        
        function obj = loadobj(s)
            obj = nb_bd.unstruct(s);
        end
           
        varargout = getLocInd(varargin)
        varargout = initialize(varargin)
        varargout = nan(varargin)
        varargout = ones(varargin)
        varargout = rand(varargin)
        varargout = unstruct(varargin)
        varargout = zeros(varargin)

    end
    
    %==============================================================
    % Hidden static methods of this class
    %==============================================================
    methods (Static=true,Hidden=true)
        
        function errorConformity(errorIdentifier)
        % Throws error messages if two objects don't have the same sizes.
            
            if isempty(errorIdentifier)
                return
            end
            
            switch errorIdentifier
                case 1
                    error([mfilename,':: the start and the end dates of the two datasets must be the same'])
                case 2
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 3
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 4
                    error([mfilename,':: the datasets must have the same number of pages'])
            end
            
        end
        
        function [data, variables, startDate, locations, indicator] = interpretXlsOutput(data,variables,dates) 
            
            % Find the start and end date of the data and its frequency
            dates                       = strtrim(dates);
            [startDate, frequency, xls] = nb_date.date2freq(dates,'xls');
            periods                     = size(data,1);
            
            % Here I need to check all the dates read from the excel
            % spreadsheet
            endDate = nb_date.toDate(dates{end},frequency);
            if isempty(endDate)
                endDate = startDate + (periods - 1);
            end
            % This is the case if there are missing dates
            if endDate ~= (startDate + periods - 1)

                periods = endDate - startDate;
                if xls
                    allDates = startDate.toDates(0:periods,'xls',frequency);
                    switch frequency
                        case 1
                            dates    = char(dates);
                            dates    = cellstr(dates(:,7:end));
                            allDates = char(allDates);
                            allDates = cellstr(allDates(:,7:end));
                        case {4,12}
                            dates    = char(dates);
                            dates    = cellstr(dates(:,4:end));
                            allDates = char(allDates);
                            allDates = cellstr(allDates(:,4:end));
                    end 
                else
                    allDates = startDate.toDates(0:periods,'default',frequency);
                end
                try
                    [~,ind] = ismember(dates,allDates);
                catch %#ok<CTCH>
                   error([mfilename ':: Some time periods are missing, but can''t figure out how...']) 
                end
                
            end
                
            % Find if we have missing elements in elements of data -
            % not just missing dates across all variables
            tempData    = data;
            data        = nan(periods + 1,size(data,2));
            data(ind,:) = tempData;
            locData     = ~isnan(data);

            % Take the logical and of the two arrays
            %locations = locData & locDates;
            locations = locData;

            % Make sure we are saving the minimum amount of data 
            numOnes = sum(locations(:));
            if numOnes > (numel(locations) / 2)
                locations = ~locations;
                indicator = 0;
            else
                locations = logical(locations);
                indicator = 1;
            end
            locations = sparse(locations);         
            
        end
        
        varargout = getDiff(varargin)
        varargout = locateVariables(varargin)
        varargout = removeDuplicates(varargin)
        
    end
    
end
