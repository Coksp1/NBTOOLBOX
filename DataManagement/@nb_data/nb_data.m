classdef nb_data < nb_dataSource
% Description:
%
% A class representing data with links to the variable names. 
% 
% Constructor:      
%
%   obj = nb_data(datasets,NameOfDatasets,startObs,variables)
%   obj = nb_data(datasets,NameOfDatasets,startObs,variables,sorted)
% 
%   Input:
% 
%   - datasets       :
%
%       Input can be one of the data types listed below:       
%  
%       - xls(x)  : A name of the excel spreadsheet to import.  
%                   (With or without extension.)
%
%                   Caution : If you read a specific worksheet, and
%                             want the object to be updateable
%                             you must provide the extension.
%                   
%                   Caution : The first column of the worksheet must start
%                             with 'obs' or 'observations', and the rest
%                             of the column you must provide the
%                             observation number ro each row. E.g:
%
%                             'obs'  | 'Var1'
%                             _______________
%                               1    |   2.5
%                             _______________
%                               2    |   2.0
% 
%       - mat     : Name(s) of the .mat files to import. (With or 
%                   without extension.). 
% 
%                   Format of the .mat file:
%                   
%                   The .mat file must be saved structure with the 
%                   fieldnames as the variable names and the fields
%                   as the data of the variables, as doubles. Plus 
%                   it must have a field with name 'startObs' with
%                   the start obs of the data, as an integer.
%                   
%       - double  : As double matrix. Each page of the matrix will 
%                   be added as separate datasets.  
% 
%       - struct  : As a structure of either double matrices. Each field is  
%                   added as separate datasets.
%         
%        You can also give a cell array consisting of one or a 
%        combination of the data types mentioned above. Each cell  
%        will be added as a new dataset. 
%     
%        Extra: Use the method structure2nb_data function to add all  
%               the fields of the structure as variables in an 
%               nb_data object. (If each field has more page then 1,  
%               then each page will be a datasets)
%
%   - NameOfDatasets :
%
%       Input options will depend on data types listed below:       
%  
%       - xls(x)  : A string with the wanted dataset name. Default 
%                   is the excel file name. If the provided string
%                   is a sheet of the read spreadsheet that 
%                   specific worksheet will be read.
% 
%       - mat     : A string with the wanted dataset name. Default 
%                   is the .mat file name.                 
% 
%       - double  : A string with the wanted dataset name. Default 
%                   is 'Dataset1'.  
%
%                   Caution: When you given double matrices which 
%                            has more pages then one, either 
%                            directly or through a struct. Each of 
%                            the pages will be added as a dataset. 
%                            The name of this datasets will, if the 
%                            input NameOfDatasets has the same size 
%                            as the input datasets, get the name 
%                            NameOfDatasets{jj}<jj>, where jj is 
%                            the page number, or else get the name 
%                            'Database<jj>'. 
% 
%       - struct  : This input has nothing to say. The dataset 
%                   names will be given by the fieldnames.
%
%       - A cell array of the listed types above:
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
%        given by a cellstr with the excel file names, .mat file  
%        names or a FAME path names, then the default dataset names 
%        will be set to the same cellstr. Or if some elements of  
%        the cell is a struct, then the datasets provided through 
%        the struct will get their fieldnames as the dataset names. 
%
%   - startDate      :
% 
%       The start date of the data. Only needed when you give 
%       numerical data as one element of the input datasets (also  
%       when numerical data is given through a struct). Default is 1.
%
%   - variables      :
% 
%       A cellstr array of the names of the variables. 
%         
%       Needed when the dataset input is:
%         
%        > Numerical matrix. The number of variables must be of the  
%          same as the size of the data (2. dimension).
%         
%        > A struct consiting of double matrices.
%
%        > When you give a cell array of one of the types mentioned
%          above.
% 
%   - sorted        : true or false. Default is true.
%
%   Output:
% 
%   - obj            : An object of class nb_data
%
%   Examples:
% 
%   - xls(x):
%             
%       One excel spreadsheet
%         
%       obj = nb_data('test1')
%         
%       More excel spreadsheets
%            
%       obj = nb_data({'test1','test2',...})
%             
%       same as
%         
%       obj = nb_data({'test1','test2',...},{'test1','test2',...})
%         
%   - mat:
%         
%   	One .mat file
%         
%       obj = nb_data('test1')
%         
%       More .mat files
%         
%       obj = nb_data({'test1','test2',...})
%         
%       same as
%         
%       obj = nb_data({'test1','test2',...},{'test1','test2',...})
%         
%   -struct: 
%         
%      One struct
%
%      > Consisting of double matrices:
%         
%         obj = nb_data(struct1,{},1,{'Var1','Var2',...})
%         
%      More structs
%             
%      > Consisting of double matrices:
%         
%         obj = nb_data({struct1,stuct2,...},{},1,...
%                     {'Var1','Var2',...})
%         
%  - double matrix:
%         
%      One matrix
%         
%      obj = nb_data(double1,'',1,{'Var1','Var2',...})
%         
%      obj = nb_data(double1,'test1',1,{'Var1','Var2',...})
%         
%      More matrices
%  
%      obj = nb_data({double1,double2,...},{},1,...
%                  {'Var1','Var2',...})
%         
%      obj = nb_data({double1,double2,...},{'name1','name2',...},...
%                  1,{'Var1','Var2',...})
%         
%      One matrix with more pages:
%         
%      obj = nb_data(double1,{},1,{'Var1','Var2',...})
%         
%      obj = nb_data(double1,{'name1','name2',...},1,...
%                  {'Var1','Var2',...})      
% 
% See also: 
% nb_cs, nb_ts, nb_graph_ts, nb_graph_cs, nb_graph_data
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected,Dependent=true)
        
        % Number of observation of the data stored 
        % in the object. As an integer.
        numberOfObservations    = 0;                
        
 
    end
    properties
        
        % The end obs of the data. As an integer.
        endObs                  = [];       
        
        % The start obs of the data. As an integer.
        startObs                = [];
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function obj = nb_data(datasets,NameOfDatasets,startObs,variables,sorted)
        % Constructor      
            
            if nargin < 5
                sorted = true;
                if nargin < 4
                    variables = {};
                    if nargin < 3
                        startObs = [];
                        if nargin < 2
                            NameOfDatasets = {};
                            if nargin < 1
                               datasets = {}; 
                            end
                        end
                    end
                end
            end
            
            obj        = obj@nb_dataSource;
            obj.sorted = sorted;
            
            if ~isempty(datasets)
                
                if isnumeric(datasets) || islogical(datasets)  || isa(datasets,'nb_distribution')
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                   
                    try
                        obj = addDataset(obj,datasets,NameOfDatasets,startObs,variables);
                    catch Err
                        
                        if ~iscellstr(NameOfDatasets)
                            rethrow(Err);
                        end
                        
                        if size(datasets,3) == size(NameOfDatasets,2)
                            obj           = addDataset(obj,datasets,'',startObs,variables);
                            obj.dataNames = NameOfDatasets;
                        else
                            rethrow(Err);
                        end
                                 
                    end
                    
                elseif ischar(datasets)
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                    
                    obj = addDataset(obj,datasets,NameOfDatasets,startObs,variables);
                    
                elseif isstruct(datasets)
                    
                    datasets = {datasets};
                    
                    obj = addDatasets(obj,datasets,{},startObs,variables);
                    
                elseif isa(datasets,'DataPackage.Data')
                    
                    obj = nb_data(datasets.getData(),cell(datasets.getDataNames())',char(datasets.getStartObsAsString()),cell(datasets.getVariables())',sorted);
                    
                else
                    try
                        obj = addDatasets(obj,datasets,NameOfDatasets,startObs,variables);
                    catch Err
                        
                        if iscell(datasets)
                            rethrow(Err)
                        else
                            
                            if strcmp(Err.identifier,'nb_data:addDatasets:inputMustBeACell')
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
            value = size(obj.data,1);
        end
        
    end
        
    %======================================================================
    % Methods saved in seperate files
    %======================================================================
    methods
        
        
    end
    
    methods (Access=public,Hidden=true)
        
        function [isOK,errorIdentifier] = checkConformity(obj,DB)
        % Syntax:
        %
        % [isOK,errorIdentifier] = checkConformity(obj,DB)
        %
        % Description:
        %
        % Static method of the nb_data class
        % 
        % Checks if two nb_ts objects have the same dimensions and
        % variables
        %
        % Written by Kenneth S. Paulsen

            isOK = 0;

            if obj.startObs ~= DB.startObs || obj.endObs ~= DB.endObs
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
        
    end
    
    %{
    =======================================================================
    Protected methods of this class
    =======================================================================
    %}
    methods (Access=protected)
        
        function [obj, dataOfNewDataBase] = updateData(obj,variablesOfNewDataBase,dataOfNewDataBase)
        % Syntax:
        %
        % [obj, dataOfNewDataBase] = updateData(obj,...
        %       variablesOfNewDataBase,dataOfNewDataBase)
        %
        % Description:
        %
        % Update obj.data, when variables are different for the existing 
        % and added dataset to the nb_ts object.
        % 
        % Written by Kenneth S. Paulsen    

            % Find the variables not contain in both datasets
            newVariables = nb_ts.getDiff(variablesOfNewDataBase,obj.variables);
            if obj.sorted
                obj.variables = sort([obj.variables, newVariables]);
            else
                obj.variables = [obj.variables, newVariables];
            end
            
            % New variables found in the new dataset
            indexNewVariables       = nb_findIndex(newVariables,obj.variables);
            indexNNV                = ~indexNewVariables;
            transData               = nan(size(obj.data,1),size(obj.data,2) + size(newVariables,2),size(obj.data,3));
            transData(:,indexNNV,:) = obj.data;
            obj.data                = transData;

            % Variables not found in the new dataset
            [ind,loc]          = ismember(variablesOfNewDataBase,obj.variables);
            loc                = loc(ind);
            transData          = nan(size(dataOfNewDataBase,1),size(obj.data,2),size(dataOfNewDataBase,3));
            transData(:,loc,:) = dataOfNewDataBase;
            dataOfNewDataBase  = transData;

        end
        
        function obj = evalStatOperator(obj,func,notHandleNaN,outputType,dimension,extraInp)
            
            oldObj = obj;
            
            if notHandleNaN
                
                switch lower(outputType)
                    case 'nb_data'
                        
                        values = func(obj.data,extraInp{:},dimension);
                        switch dimension
                            case 1
                                values = values(ones(1,obj.numberOfObservations),:,:);
                            case 2
                                values = values(:,ones(1,obj.numberOfVariables),:,:);
                            case 3
                                values = values(:,:,ones(1,obj.numberOfDatasets));
                        end
                        obj.data = values;
                        
                    case {'double','nb_data_scalar'}
                        
                        values = func(obj.data,extraInp{:},dimension);
                        if strcmpi(outputType,'double')
                            obj = values;
                        else

                            switch dimension
                                case 1
                                    error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''' outputType '''.'])
                                case 2
                                    obj = nb_data(values,obj.dataNames,obj.startObs,{func2str(func)},obj.sorted);
                                case 3
                                    obj = nb_data(values,func2str(func),obj.startObs,obj.variables,obj.sorted);
                            end

                        end
                        
                    case 'nb_cs'

                        switch dimension
                            case 1   
                            otherwise  
                                error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''nb_cs''.'])     
                        end
                        values             = func(obj.data,extraInp{:},dimension);
                        locVars            = obj.localVariables;
                        obj                = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);
                        obj.localVariables = locVars;
                        
                end
                return
                
            end
            
            % I cannot vectorize here because the function mean made by
            % matlab does not handle nan values as wanted.
            switch lower(outputType)

                case 'nb_data'

                    switch dimension

                        case 1

                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfDatasets

                                    isNotNan                 = ~isnan(obj.data(:,ii,jj));
                                    inp                      = {obj.data(isNotNan,ii,jj)};
                                    inp                      = [inp,extraInp]; %#ok<AGROW>
                                    obj.data(isNotNan,ii,jj) = func(inp{:});

                                end

                            end

                        case 2

                            for ii = 1:obj.numberOfDatasets

                                for jj = 1:obj.numberOfObservations

                                    isNotNan                 = ~isnan(obj.data(jj,:,ii));
                                    inp                      = {obj.data(jj,isNotNan,ii)};
                                    inp                      = [inp,extraInp]; %#ok<AGROW>
                                    obj.data(jj,isNotNan,ii) = func(inp{:});

                                end

                            end

                        case 3

                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfObservations

                                    isNotNan                 = ~isnan(obj.data(jj,ii,:));
                                    inp                      = {obj.data(jj,ii,isNotNan)};
                                    inp                      = [inp,extraInp]; %#ok<AGROW>
                                    obj.data(jj,ii,isNotNan) = func(inp{:});

                                end

                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the dimension '  int2str(dimension) '.'])

                    end

                case {'double','nb_data_scalar'}

                    switch dimension

                        case 1

                            values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);

                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfDatasets

                                    isNotNan        = ~isnan(obj.data(:,ii,jj));
                                    inp             = {obj.data(isNotNan,ii,jj)};
                                    inp             = [inp,extraInp]; %#ok<AGROW>
                                    values(1,ii,jj) = func(inp{:});

                                end

                            end

                        case 2

                            values = nan(obj.numberOfObservations,1,obj.numberOfDatasets);

                            for ii = 1:obj.numberOfDatasets

                                for jj = 1:obj.numberOfObservations

                                    isNotNan        = ~isnan(obj.data(jj,:,ii));
                                    inp             = {obj.data(jj,isNotNan,ii)};
                                    inp             = [inp,extraInp]; %#ok<AGROW>
                                    values(jj,1,ii) = func(inp{:});

                                end

                            end

                        case 3

                            values = nan(obj.numberOfObservations,obj.numberOfVariables,1);
                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfObservations

                                    isNotNan        = ~isnan(obj.data(jj,ii,:));
                                    inp             = {obj.data(jj,ii,isNotNan)};
                                    inp             = [inp,extraInp]; %#ok<AGROW>
                                    values(jj,ii,1) = func(inp{:});

                                end

                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the dimension '  int2str(dimension) '.'])

                    end

                    if strcmpi(outputType,'double')
                        obj = values;
                    else
                        
                        switch dimension
                            case 1
                                error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output i set to ''' outputType '''.'])
                            case 2
                                obj = nb_data(values,obj.dataNames,obj.startObs,{func2str(func)},obj.sorted);
                            case 3
                                obj = nb_data(values,func2str(func),obj.startObs,obj.variables,obj.sorted);
                        end
                        
                    end

                case 'nb_cs'

                    switch dimension
                        case 1   
                        otherwise  
                            error([mfilename ':: Cannot take the ' func2str(func) ' over the dimension '  int2str(dimension) ', when the demanded output is set to ''nb_cs''.'])     
                    end

                    values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);

                    for ii = 1:obj.numberOfVariables

                        for jj = 1:obj.numberOfDatasets

                            isNotNan        = ~isnan(obj.data(:,ii,jj));
                            inp             = {obj.data(isNotNan,ii,jj)};
                            inp             = [inp,extraInp]; %#ok<AGROW>
                            values(1,ii,jj) = func(inp{:});

                        end

                    end

                    obj = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);

                otherwise

                    error([mfilename ':: Non supported output type; ' outputType])

            end
            
            if oldObj.isUpdateable() 

                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                if strcmpi(outputType,'nb_data')

                    obj = obj.addOperation(func,[extraInp, {outputType,dimension}]);

                elseif strcmpi(outputType,'nb_cs') || strcmpi(outputType,'nb_data_scalar')

                    oldObj = oldObj.addOperation(func,[extraInp, {outputType,dimension}]);
                    linksT = oldObj.links;
                    obj    = obj.setLinks(linksT);

                end

            end
            
        end
        
        function [startObsWin,endObsWin,variablesWin,startInd,endInd,variablesInd,pages] = getWindow(obj,startObsWin,endObsWin,variablesWin,pages)
            
            % Which obs to keep
            if isempty(startObsWin) || isnan(startObsWin)
                startInd    = 1;
                startObsWin = obj.startObs;
            else
                startInd = (startObsWin - obj.startObs) + 1;
                if startInd < 1
                    error([mfilename ':: beginning of window (''' int2str(startObsWin) ''') starts before the start obs (''' int2str(obj.startObs) ''') '...
                                     'or starts after the end obs (''' int2str(obj.endObs) ''') of the data '])
                end
            end

            if isempty(endObsWin) || isnan(endObsWin)
                endInd    = obj.numberOfObservations;
                endObsWin = obj.endObs;
            else
                endInd = (endObsWin - obj.startObs) + 1;
                if endInd > obj.numberOfObservations
                    error([mfilename ':: end of window (''' int2str(endObsWin) ''') ends after the end date (''' int2str(obj.endObs) ''') or '...
                                     'ends before the start date (''' int2str(obj.startObs) ''') of the data '])
                end
            end

            % Remove all other variables not given in the cellstr variables
            if ~isempty(variablesWin)

                variablesWin = cellstr(variablesWin);
                variablesInd = zeros(1,max(size(obj.variables)));
                for ii = 1:max(size(variablesWin))
                    var_id       = strcmp(variablesWin{ii},obj.variables);
                    variablesInd = variablesInd + var_id;
                    if sum(var_id)==0
                        warning('nb_ts:window:VariableNotFound',[mfilename ':: Variable ''' variablesWin{ii} ''' not found.']) 
                    end
                end
                variablesInd = logical(variablesInd);

            else
                variablesInd = 1:size(obj.variables,2); % To ensure that we keep all variables
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
                    pages = nb_ts.locateVariables(pages,obj.dataNames);
                end
            end
            
        end
        
    end
    
    %==============================================================
    % Protected static methods of this class
    %==============================================================
    methods (Static=true, Access=protected, Hidden=true)
        
        function [data, variables, startObs, endObs, userData, localVariables] = dataset2Properties(dataset,startObs,var,vintage,sorted)
        % Description:
        %
        % A static method of the nb_data class 
        %
        % Load properties (data) from .xls file
        % 
        % Written by Kenneth S. Paulsen

            if nargin < 4
                vintage = '';
                if nargin < 3
                    var = {};
                end
            end
            userData       = '';
            localVariables = [];

            if isnumeric(dataset) || islogical(dataset) || isa(dataset,'nb_distribution')

                if isempty(startObs)
                    warning(['Start obs of data is not given, 1 is default. '...
                             '(This is only important if the data is given from a .mat file or as a double matrix)']) %
                    startObs = 1;
                end

                if isempty(dataset)

                    % Return these values to get a good error message
                    data      = [];
                    variables = var;
                    startObs  = [];
                    endObs    = [];

                else
                    
                    tempData     = dataset;
                    notSortedVar = strtrim(cellstr(var));

                    if size(notSortedVar,2)==1
                        notSortedVar =  notSortedVar'; 
                    end

                    variables = nb_ts.removeDuplicates(sort(notSortedVar));                
                    data      = nan(size(tempData,1),size(tempData,2),size(tempData,3));
                    if size(variables,2) == size(tempData,2) % Just to make it to the error message in addDataset method instead

                        if sorted
                            % Reallocate given that the variables is sorted
                            [~,loc] = ismember(variables,notSortedVar);
                            data    = tempData(:,loc,:);
                        else
                            data      = tempData; 
                            variables = notSortedVar;
                        end
                        
                        % Check that no variables are empty
                        ind       = ~cellfun('isempty',variables);
                        variables = variables(ind);
                        data      = data(:,ind,:);
                        
                    end

                    if ischar(startObs)

                        startObs = str2double(startObs);
                        if isempty(startObs) || mod(startObs,1) ~= 0
                            error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
                        end
                        
                    elseif ~(isnumeric(startObs) && mod(startObs,1) == 0)
                        error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
                    end

                    periods  = size(data,1);
                    endObs   = startObs + periods - 1;

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
                                        type = 'splittedxls';
                                    end
                                end
                            end
                        end
                    end
                end

                switch lower(type)

                    case 'xlsx'

                        sheet = vintage;
                        [data, variables, startObs, endObs] = nb_data.xls2Properties([dataset '.xlsx'],sheet,sorted);

                    case 'xlsm'
                        
                        sheet = vintage;
                        [data, variables, startObs, endObs] = nb_data.xls2Properties([dataset '.xlsm'],sheet,sorted);    
                        
                    case 'csv'
                        
                        sheet = vintage;
                        [data, variables, startObs, endObs] = nb_data.xls2Properties([dataset '.csv'],sheet,sorted);    
                        
                    case 'mat'

                        temp = load(dataset);
                        [data, variables, startObs, endObs, userData, localVariables] = nb_data.structure2Properties(temp,[],sorted); % Here we assume that the startDate are the same for all databases

                    case 'xls'

                        sheet = vintage;
                        [data, variables, startObs, endObs] = nb_data.xls2Properties(dataset,sheet,sorted);

                    otherwise
                        error(['Did not find; ' dataset ', ' dataset '.xlsx, ' dataset '.xls or ' dataset '.mat in the current folder.']);
                end
            else
                error([mfilename ':: Dataset is not a string with name of mat file or xls file or a double matrix with data (variables must then be given).'])
            end

        end
        
        function [data, variables, startObs, endObs, userData, localVariables] = structure2Properties(structure,startObs,sorted)
        % Description:
        %
        % Static method of the nb_data class
        % 
        % Load properties from a structure of double vectors
        %
        % Written by Kenneth S. Paulsen

            if isfield(structure,'localVariables')
                localVariables = structure.localVariables;
            else
                localVariables = [];
            end
        
            if isfield(structure,'variables')
                [data, variables, startObs, endObs, userData] = nb_data.structure2PropertiesNew(structure,startObs,sorted);
                return
            end
            variables = fieldnames(structure)';

            if nargin < 2
                startObs = '';
            end

            if isempty(startObs)

                % Load the start date from the structure
                found = find(strcmpi('startObs',variables),1);
                if isempty(found)
                    startObs = 1;
                else
                    startObs = structure.(variables{found});
                end
                
            else

                found = 0;

            end
            
            if ~isempty(found)
                variables = [variables(1:found-1) variables(found+1:end)];
            end
            
            if ischar(startObs)

                startObs = str2double(startObs);
                if isempty(startObs) || mod(startObs,1) ~= 0
                    error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
                end

            elseif ~(isnumeric(startObs) && mod(startObs,1) == 0)
                error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
            end

            foundUD  = find(strcmpi('userData',variables),1);
            userData = '';
            if ~isempty(foundUD)
                userData  = structure.(variables{foundUD});
                variables = [variables(1:foundUD-1) variables(foundUD+1:end)];
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
            [r,c,p]       = size(structure.(variablesTemp{1}));
            if r == 1
                r = c;
            end
            data = nan(r,length(variables),p);
            for j = 1:size(variablesTemp,2)
                data(:,j,:) = structure.(variablesTemp{j});
            end

            if isa(data,'ts')
               data.varnames = variablesTemp;
            end
            
            % Get the end date
            periods = size(data,1);
            endObs  = startObs + periods - 1;
            
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_ts.locateVariables(variables,variablesTemp);  
            if sorted
                data = data(:,ind,:); 
            else
                variables = variablesTemp;
            end

        end
        
        function [data, variables, startObs, endObs, userData] = structure2PropertiesNew(structure,startObs,sorted)
        % Description:
        %
        % Static method of the nb_data class
        % 
        % Load properties from a structure of double vectors
        %
        % Written by Kenneth S. Paulsen

            variables = structure.variables;

            if nargin < 2
                startObs = '';
            end

            if isempty(startObs)
                startObs = structure.startObs; 
            end
            
            if ischar(startObs)

                startObs = str2double(startObs);
                if isempty(startObs) || mod(startObs,1) ~= 0
                    error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
                end

            elseif ~(isnumeric(startObs) && mod(startObs,1) == 0)
                error([mfilename ':: the ''startObs'' input must either be a string (with an integer) or an integer.'])
            end
            userData  = structure.userData;
            
            % Load the variables from the structure
            variablesTemp = variables;
            [r,c,p]       = size(structure.Var1);
            if r == 1
                r = c;
            end
            data = nan(r,length(variables),p);
            for j = 1:size(variablesTemp,2)
                data(:,j,:) = structure.(['Var' int2str(j)]);
            end

            if isa(data,'ts')
               data.varnames = variablesTemp;
            end
            
            % Get the end date
            periods = size(data,1);
            endObs  = startObs + periods - 1;
            
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_ts.locateVariables(variables,variablesTemp);  
            if sorted
                data = data(:,ind,:); 
            else
                variables = variablesTemp;
            end

        end
        
        function [data, variables, startObs, endObs] = xls2Properties(xls,sheet,sorted)
        % Syntax:
        %
        % [data, variables, startObs, endObs, frequency] = ...
        %            nb_ts.xls2Properties(xls,sheet,sorted)
        %
        % Description:
        %
        % Static method of the nb_ts class 
        %
        % Load from excel spreadsheet to properties of nb_ts
        % 
        % Written by Kenneth S. Paulsen

            c         = nb_xlsread(xls,sheet);
            obj       = nb_cell2obj(c,true,sorted);
            data      = obj.data;
            variables = obj.variables;
            startObs  = obj.startObs;
            endObs    = obj.endObs;
            
        end
        
    end
    
    %==============================================================
    % Static methods of this class
    %==============================================================
    methods (Static=true)
        
        function obj = loadobj(s) 
            obj = nb_data.unstruct(s);
        end
        
        varargout = rand(varargin)  
        varargout = nan(varargin)
        varargout = ones(varargin)
        varargout = zeros(varargin)
        varargout = fromRise_ts(varargin)
        varargout = unstruct(varargin)

    end
    
    %==============================================================
    % Hidden static methods of this class
    %==============================================================
    methods (Static=true,Hidden=true)
        
        function [data, variables, startObs, endObs] = interpretXlsOutput(data,variables,obs)
            
            % Find the start and end date of the data and its frequency
            obs = str2num(char(obs)); %#ok<ST2NM>
            if isempty(obs)
                error([mfilename ':: When the excel spreadsheet is interpreted as dimensionless data the first column must be numeric'])
            end
            startObs = obs(1);
            if isempty(startObs) || mod(startObs,1) ~= 0
                error([mfilename ':: The first column of the worksheet (2 row and on) must contain the observation numbers. I.e. 1,2,3,4...'])
            end
            endObs  = obs(end);
            periods = size(data,1);
            
            % Here I need to check all the dates read from the excel
            % spreadsheet
            if endObs ~= (startObs + periods - 1)

                allPeriods = startObs:endObs;
                try
                    [~,locations] = ismember(obs,allPeriods);
                catch %#ok<CTCH>
                   error([mfilename ':: Some time periods are missing, but can''t figure out how...']) 
                end
                tempData          = data;
                data              = nan(periods + 1,size(data,2));
                data(locations,:) = tempData;

            end
            
        end
        
        function errorConformity(errorIdentifier)
        % Syntax:
        %
        % errorConformity(errorIdentifier)
        %
        % Description
        %
        % Throws error messages if two objects don't have the same sizes.
        %
        % Input:
        %
        % - errorIdentifier : A error message identifier thrown by the 
        %                     checkConformity method of the class nb_data
        %
        % Output:
        %
        % - A proper error message
        % 
        % Written by Kenneth S. Paulsen

            if isempty(errorIdentifier)
                return
            end
        
            switch errorIdentifier
                case 1
                    error([mfilename,':: the start and the end observations of the two datasets must be the same'])
                case 2
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 3
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 4
                    error([mfilename,':: the datasets must have the same number of pages'])
            end

        end
         
    end
    
end
