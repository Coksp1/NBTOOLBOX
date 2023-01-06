classdef nb_cs < nb_dataSource
% Description:
%
% A class for storing cross-sectional data (Case data)  
%    
% Constructor:      
%
%   obj = nb_cs(datasets,NameOfDatasets,types,variables)
%   obj = nb_cs(datasets,NameOfDatasets,types,variables,sorted)
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
%                 without extension.). As a string. This .mat 
%                 file must store a struct where each field stores 
%                 the data of a variable. The data stored at each 
%                 field must be doubles with same size. The only 
%                 exception is that you must include a field called
%                 'types', storing a cellstr with the types of the
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
%      Extra: Use the method structure2nb_cs function to add all 
%             the fields of the structure as variables in an 
%             nb_cs object. (If each field has more page then 1, 
%             then each page will be a new datasets). See the 
%             method structure2nb_cs for more on the supported 
%             format of the structure you can provide as input.
%         
%   - NameOfDatasets :
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
%                          input NameOfDatasets has the same size 
%                          as the input datasets, get the name 
%                          NameOfDatasets{jj}<jj>, where jj is 
%                          the page number, or else get the name 
%                          'Database<jj>'.
% 
%      - struct : This input has nothing to say. The dataset 
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
%   - types :    
%         
%      A cell array of the type names of the data, as strings. Only
%      needed when you give a double or a struct of doubles as the 
%      datasets input. The number of types must be the same as the 
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
%   - obj      : An object of class nb_cs.
% 
%   Examples:
% 
%   - xls(x):
%             
%      One excel spreadsheet
%         
%      obj = nb_cs('test1')
%         
%      More excel spreadsheets
%            
%      obj = nb_cs({'test1','test2',...})
%             
%      same as
%         
%      obj = nb_cs({'test1','test2',...},{'test1','test2',...})
%         
%   - mat:
%         
%      One .mat file:
%         
%      obj = nb_cs('test1')
%         
%      More .mat files:
%         
%      obj = nb_cs({'test1','test2',...})
%         
%      same as
%         
%      obj = nb_cs({'test1','test2',...},{'test1','test2',...})
%         
%   -struct: 
%         
%     One struct (Consisting of double matrices):
%         
%     obj = nb_cs(struct1,{},{'Type1','Type2',...},...
%                    {'Var1','Var2',...})
%         
%     More structs:
%         
%     obj = nb_cs({struct1,stuct2,...},{},{'Type1','Type2',...},...
%                 {'Var1','Var2',...})
%         
%   - double matrix:
%         
%      One matrix
%         
%      obj = nb_cs(double1,'',{'Type1','Type2',...},...
%                  {'Var1','Var2',...})
%         
%      obj = nb_cs(double1,'test1',{'Type1','Type2',...},...
%                  {'Var1','Var2',...})
%         
%      More matrices
%  
%      obj = nb_cs({double1,double2,...},{},....
%                  {'Type1','Type2',...},{'Var1','Var2',...})
%         
%      obj = nb_cs({double1,double2,...},{'name1','name2',...},...
%                  {'Type1','Type2',...},{'Var1','Var2',...})
%         
%      One matrix with more pages:
%         
%      obj = nb_cs(double1,{},{'Type1','Type2',...},...
%                  {'Var1','Var2',...})
%         
%      obj = nb_cs(double1,{'name1','name2',...},...
%                  {'Type1','Type2',...},{'Var1','Var2',...})
% 
% See also: 
% nb_graph_cs, nb_ts, nb_graph_ts
% 
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen


    properties (SetAccess=protected,Dependent=true)

        % Number of types of the object. As a double. 
        numberOfTypes = 0;   
        
    end

    properties
        
        % Description/names of the data types. As a cellstr.
        types = {};  

    end
    
    %{
    -----------------------------------------------------------------------
    Accessible methods
    -----------------------------------------------------------------------
    %}
    methods

        function obj = nb_cs(datasets,NameOfDatasets,types,variables,sorted)
        % Constructor:      
        %
        % Written by Kenneth Sæterhagen Paulsen
            
            if nargin<5
                sorted = true;
                if nargin < 4
                    variables = {};
                    if nargin < 3
                        types = {};
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
                
                if isnumeric(datasets) || isa(datasets,'nb_distribution')
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                   
                    try
                        obj = addDataset(obj,datasets,NameOfDatasets,types,variables);
                    catch Err
                        
                        if ~iscellstr(NameOfDatasets)
                            rethrow(Err);
                        end
                        
                        if size(datasets,3) == size(NameOfDatasets,2)
                            obj           = addDataset(obj,datasets,'',types,variables);
                            obj.dataNames = NameOfDatasets;
                        else
                            rethrow(Err);
                        end
                                 
                    end
                    
                elseif ischar(datasets) 
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                   
                    obj = addDataset(obj,datasets,NameOfDatasets,types,variables);
                    
                elseif isstruct(datasets)
                    
                    datasets = {datasets};
                    
                    obj = addDatasets(obj,datasets,{},types,variables);
                    
                else
                    
                    obj = addDatasets(obj,datasets,NameOfDatasets,types,variables);
                
                end
                
            end
            
        end
        
        function value = get.numberOfTypes(obj)
            value = size(obj.data,1);
        end
 
    end
    
    %{
    -----------------------------------------------------------------------
    Accessible methods which are not in seperate files
    -----------------------------------------------------------------------
    %}
    methods (Access=public,Hidden=true)
        
        function [isOK,errorIdentifier] = checkConformity(obj,DB)
        % Syntax:
        %
        % [isOK,errorIdentifier] = checkConformity(obj,DB)
        %
        % Description:
        %
        % Static method of the nb_ts class
        % 
        % Checks if two nb_ts objects have the same dimensions and
        % variables
        % 
        % Examples:
        % 
        % Written by Kenneth S. Paulsen

            isOK = 0;

            if obj.numberOfTypes ~= DB.numberOfTypes
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
                    ind = obj.numberOfTypes;
                case 2
                    ind = obj.numberOfVariables;
                case 3
                    ind = obj.numberOfDatasets;
            end
            
        end
         
    end
    
    %{
    -----------------------------------------------------------------------
    Protected methods
    -----------------------------------------------------------------------
    %}
    methods (Access=protected)
        
        function [obj, dataOfNewDataBase] = updateData(obj,cellStr,dataOfNewDataBase,type)
        % Syntax:
        %
        % [obj, dataOfNewDataBase] = updateData(obj,cellStr,...
        %                               dataOfNewDataBase,type)
        %
        % Description:
        %
        % Protected method
        % 
        % Update obj.data, when variables ore types is different for the obj 
        % and the new dataset.
        % 
        % Written by Kenneth S. Paulsen

            switch type

                case 'variables'

                    % Find the variables not contain in both datasets
                    newVariables = nb_cs.getDiff(cellStr,obj.variables);
                    if obj.sorted
                        obj.variables = sort([obj.variables, newVariables]);
                    else
                        obj.variables = [obj.variables, newVariables];
                    end
                    
                    % New variables found in the new dataset
                    indexNewVariables = nb_findIndex(newVariables,obj.variables);
                    indexNNV          = ~indexNewVariables;
                    transData         = nan(size(obj.data,1),size(obj.data,2) + size(newVariables,2),size(obj.data,3));
                    if isa(obj.data,'nb_distribution')
                        transData = nb_distribution.double2Dist(transData);
                    end
                    transData(:,indexNNV,:) = obj.data;
                    obj.data = transData;

                    % Variables not found in the new dataset
                    [ind,loc] = ismember(cellStr,obj.variables);
                    loc       = loc(ind);
                    transData = nan(size(dataOfNewDataBase,1),size(obj.data,2),size(dataOfNewDataBase,3));
                    if isa(dataOfNewDataBase,'nb_distribution')
                        transData = nb_distribution.double2Dist(transData);
                    end
                    transData(:,loc,:) = dataOfNewDataBase;
                    dataOfNewDataBase  = transData;
                    
                case 'types'

                    % Find the types not contain in both datasets
                    [newTypes,typesNotInNew] = nb_cs.getDiff(cellStr,obj.types);

                    if ~isempty(newTypes)
                        % New types found in the new dataset
                        obj.types     = [obj.types newTypes];
                        indexNewTypes = nb_findIndex(newTypes,obj.types);
                        indexNNT      = ~indexNewTypes;
                        transData     = nan(size(obj.data,1) + size(newTypes,2),size(obj.data,2),size(obj.data,3));
                        if isa(obj.data,'nb_distribution')
                            transData = nb_distribution.double2Dist(transData);
                        end
                        transData(indexNNT,:,:) = obj.data;
                        obj.data = transData;
                    end

                    if ~isempty(typesNotInNew)
                        % Types not found in the new dataset
                        [ind,loc] = ismember(cellStr,obj.types);
                        loc       = loc(ind);
                        transData = nan(size(obj.data,1),size(dataOfNewDataBase,2),size(dataOfNewDataBase,3));
                        if isa(dataOfNewDataBase,'nb_distribution')
                            transData = nb_distribution.double2Dist(transData);
                        end
                        transData(loc,:,:) = dataOfNewDataBase;
                        dataOfNewDataBase  = transData;
                    end


            end

        end
        
        function [typesWin,variablesWin,typesInd,variablesInd,pages] = getWindow(obj,typesWin,variablesWin,pages)
            
            % Remove all other types not given in the cellstr typesWin
            if ~isempty(typesWin)

                typesWin = cellstr(typesWin);

                typesInd = zeros(1,max(size(obj.types)));
                for ii = 1:max(size(typesWin))
                    var_id = strcmp(typesWin{ii},obj.types);
                    typesInd = typesInd + var_id;
                    if sum(var_id)==0
                        warning('nb_cs:window:TypeNotFound',[mfilename ':: Type ''' typesWin{ii} ''' not found.']) 
                    end
                end

                typesInd = logical(typesInd);

            else

                typesInd = 1:size(obj.types,2); % To ensure that we keep all variablesWin

            end

            % Remove all other variables not given in the cellstr variables
            if ~isempty(variablesWin)

                variablesWin = cellstr(variablesWin);
                variablesInd = zeros(1,max(size(obj.variables)));
                for ii = 1:max(size(variablesWin))
                    var_id = strcmp(variablesWin{ii},obj.variables);
                    variablesInd = variablesInd + var_id;
                    if sum(var_id)==0
                        warning('nb_cs:window:VariableNotFound',[mfilename ':: Variable ''' variablesWin{ii} ''' not found.']) 
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
                    pages = nb_cs.locateStrings(pages,obj.dataNames);
                end
            end
            
        end
        
        function obj = evalStatOperator(obj,func,notHandleNaN,outputType,dimension,extraInp)
            
            oldObj = obj;
            
            if notHandleNaN
                
                switch lower(outputType)
                    case 'nb_cs'
                        
                        values = func(obj.data,extraInp{:},dimension);
                        switch dimension
                            case 1
                                values = values(ones(1,obj.numberOfTypes),:,:);
                            case 2
                                values = values(:,ones(1,obj.numberOfVariables),:,:);
                            case 3
                                values = values(ones(1,obj.numberOfDatasets),:,:);
                        end
                        obj.data = values;
                        
                    case {'double','nb_cs_scalar'}
                        
                        values = func(obj.data,extraInp{:},dimension);
                        if strcmpi(outputType,'double')
                            obj = values;
                        else

                            switch dimension
                                case 1
                                    obj = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);
                                case 2
                                    obj = nb_cs(values,obj.dataNames,obj.types,{func2str(func)},obj.sorted);
                                case 3
                                    obj = nb_cs(values,func2str(func),obj.types,obj.variables,obj.sorted);
                            end

                        end
                        
                end
                return
                
            end
            
            % I cannot vectorize here because the function mean made by
            % matlab does not handle nan values as wanted.
            switch lower(outputType)

                case 'nb_cs'

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

                                for jj = 1:obj.numberOfTypes

                                    isNotNan                 = ~isnan(obj.data(jj,:,ii));
                                    inp                      = {obj.data(jj,isNotNan,ii)};
                                    inp                      = [inp,extraInp]; %#ok<AGROW>
                                    obj.data(jj,isNotNan,ii) = func(inp{:});

                                end

                            end

                        case 3

                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfTypes

                                    isNotNan                 = ~isnan(obj.data(jj,ii,:));
                                    inp                      = {obj.data(jj,ii,isNotNan)};
                                    inp                      = [inp,extraInp]; %#ok<AGROW>
                                    obj.data(jj,ii,isNotNan) = func(inp{:});

                                end

                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the dimension '  int2str(dimension) '.'])

                    end

                case {'double','nb_cs_scalar'}

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

                            values = nan(obj.numberOfTypes,1,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfDatasets

                                for jj = 1:obj.numberOfTypes

                                    isNotNan        = ~isnan(obj.data(jj,:,ii));
                                    inp             = {obj.data(jj,isNotNan,ii)};
                                    inp             = [inp,extraInp]; %#ok<AGROW>
                                    values(jj,1,ii) = func(inp{:});

                                end

                            end

                        case 3

                            values = nan(obj.numberOfTypes,obj.numberOfVariables,1);
                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfTypes

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
                                obj = nb_cs(values,obj.dataNames,{func2str(func)},obj.variables,obj.sorted);
                            case 2
                                obj = nb_cs(values,obj.dataNames,obj.types,{func2str(func)},obj.sorted);
                            case 3
                                obj = nb_cs(values,func2str(func),obj.types,obj.variables,obj.sorted);
                        end
                        
                    end

                otherwise

                    error([mfilename ':: Non supported output type; ' outputType])

            end
            
            if oldObj.isUpdateable() && strcmpi(outputType,'nb_cs')

                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                obj = obj.addOperation(func,[extraInp {outputType,dimension}]);

            end
            
        end
        
    end
    
    %{
    -----------------------------------------------------------------------
    Protected static methods
    -----------------------------------------------------------------------
    %}
    methods (Static=true,Access=protected)
        
        function [data, variables, types, userData, localVariables] = dataset2Properties(dataset,types,variables,sheet,sorted)
        % Description:
        %
        % Static method
        % 
        % Load properties (data) from xls or mat files or double matrices
        % 
        % Written by Kenneth S. Paulsen

            userData       = '';
            localVariables = [];

            if ischar(dataset)

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

                switch type

                    case 'xlsx'

                        [data, variables, types] = nb_cs.xls2Properties([dataset '.xlsx'],sheet,sorted);

                    case 'xlsm'
                        
                        [data, variables, types] = nb_cs.xls2Properties([dataset '.xlsm'],sheet,sorted);    
                      
                    case 'csv'
                        
                        [data, variables, types] = nb_cs.xls2Properties([dataset '.csv'],sheet,sorted);    
                        
                    case 'mat'

                        temp = load(dataset);

                        % Here we assume that the structure has a field 'types' which contains the laded types to assign to the object
                        [data, variables, types, userData, localVariables] = nb_cs.structure2Properties(temp,sorted); 

                    case 'xls'

                        [data, variables, types] = nb_cs.xls2Properties(dataset,sheet,sorted);

                    otherwise
                        error(['Did not find; ' dataset ', ' dataset '.xlsx, ' dataset '.xls or ' dataset '.mat in the current folder.']);
                end

            elseif isnumeric(dataset) || isa(dataset,'nb_distribution')

                if isempty(dataset)

                    % Return these values to get a good error message
                    data      = [];

                else

                    % Sort variables and realocate the data
                    tempData      = dataset;
                    notSortedVars = cellstr(variables);

                    % Ensure that the variables is a row vector 
                    if size(notSortedVars,2)==1
                        notSortedVars =  notSortedVars'; 
                    end

                    variables = nb_cs.removeDuplicates(sort(notSortedVars));
                    [t,v,p]   = size(tempData);
                    data      = nan(t,v,p);
                    if size(variables,2) == size(tempData,2) % Just to make it to the error message in addDataset method instead

                        if sorted
                            % Reallocate given that the variables is sorted
                            [~,loc] = ismember(variables,notSortedVars);
                            data    = tempData(:,loc,:);
                        else
                            data      = tempData; 
                            variables = notSortedVars;
                        end
                        
                        % Check that no variables are empty
                        ind       = ~cellfun('isempty',variables);
                        variables = variables(ind);
                        data      = data(:,ind,:);
                        
                    end

                    % Ensure that the types input is a column vector 
                    types = cellstr(types);
                    if size(types,1)==1
                        types =  types'; 
                    end
                    
                    if size(types,1) == size(tempData,1) % Just to make it to the error message in addDataset method instead
                        
                        % Check that no variables are empty
                        ind   = ~cellfun('isempty',types);
                        types = types(ind);
                        data  = data(ind,:,:);
                        
                    end
                    
                end

            else
                error([mfilename ':: Dataset is not a dyn_ts object, a string with name of mat file or xls file or a double matrix with data (variables must then be given).'])
            end

        end
        
        function [data, variables, types, userData, localVariables] = structure2Properties(structure,sorted)
        % Description:
        %
        % Static method
        % 
        % Load from mat file to properties of nb_cs
        % 
        % Written by Kenneth S. Paulsen

            if isfield(structure,'localVariables')
                localVariables = structure.localVariables;
            else
                localVariables = [];
            end
        
            if isfield(structure,'variables')
                [data, variables, types, userData] = nb_cs.structure2PropertiesNew(structure,sorted);
                return
            end
        
            variables = fieldnames(structure)';

            % Load the types from the structure
            found = find(strcmp('types',variables),1);
            if isempty(found)
                error([mfilename ':: When loading data from a structure or a .mat file the structure or mat file must contain a field ''types'', '...
                      'which must have the same column length as the data of the variables.'])
            end
            types = structure.('types');
            types = cellstr(types);
            if size(types,1) == 1
                types = types';
            end
            variables = [variables(1:found-1) variables(found+1:end)];
            
            foundUD  = find(strcmpi('userData',variables),1);
            userData = '';
            if ~isempty(foundUD)
                userData  = structure.(variables{foundUD});
                variables = [variables(1:foundUD-1) variables(foundUD+1:end)];
            end
            
            foundC = find(strcmpi('class',variables),1);
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
             
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_ts.locateVariables(variables,variablesTemp);  
            if sorted
                data = data(:,ind,:); 
            else
                variables = variablesTemp;
            end
            
        end
        
        function [data, variables, types, userData] = structure2PropertiesNew(structure,sorted)
        % Syntax:
        %
        % [data, variables, types] = structure2Properties(structure)
        %
        % Description:
        %
        % Static method
        % 
        % Load from mat file to properties of nb_cs
        % 
        % Written by Kenneth S. Paulsen

            variables = structure.variables;

            % Load the types from the structure
            types = structure.types;
            types = cellstr(types);
            if size(types,1) == 1
                types = types';
            end
            userData = structure.userData;

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
            
            % Sort the variables if wanted and check for duplicates
            variables = sort(variablesTemp);
            ind       = nb_ts.locateVariables(variables,variablesTemp);  
            if sorted
                data = data(:,ind,:); 
            else
                variables = variablesTemp;
            end
            
        end
        
        function [data, variables, types] = xls2Properties(xls,sheet,sorted)
        % Syntax:
        %
        % [data, variables, types] = xls2Properties(xls)
        %
        % Description:
        %
        % Static method
        % 
        % Load dataset from excel spreadsheet to properties of the nb_cs 
        % object
        %
        % Written by Kenneth S. Paulsen

            c         = nb_xlsread(xls,sheet);
            obj       = nb_cell2obj(c,true,sorted);
            data      = obj.data;
            variables = obj.variables;
            types     = obj.types';
               
        end
        
    end
        
    %{
    -----------------------------------------------------------------------
    Static methods
    -----------------------------------------------------------------------
    %}
    methods (Static=true)
        
        function obj = loadobj(s)
            obj = nb_cs.unstruct(s);           
        end
        
        varargout = rand(varargin)
        varargout = ones(varargin)
        varargout = nan(varargin)
        varargout = zeros(varargin)
        varargout = unstruct(varargin)
        
    end
    
    %==============================================================
    % Hidden static methods of this class
    %==============================================================
    methods (Static=true,Hidden=true)
        
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
        %                     checkConformity method of the class nb_ts
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
                    error([mfilename,':: the number of types of the two datasets must be the same'])
                case 2
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 3
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 4
                    error([mfilename,':: the datasets must have the same number of pages'])
            end

        end
        
        function [data, variables, types] = interpretXlsOutput(data,variables,typesTemp)
            
            % Remove cell with empty type names
            types = typesTemp(~strcmp('',typesTemp)); % Remove the '' variable names. I.e. variables without names.
            types = strtrim(types);
            
            % Test the types properties
            try
                locationsT = nb_cs.locateStrings(types,typesTemp);
            catch Err
                if strcmp(Err.identifier,'nb_cs:locateStrings:DeclaredMoreThanOnce')
                    type = strrep(Err.message,'nb_cs:: string ','');
                    type = strrep(type,' declared more than once','');
                    error([mfilename ':: The type ' type ' is found more than once in the excel spreadsheet'])
                else
                    rethrow(Err);
                end
            end

            if size(types,1) == 1
                types  = types';
            end

            % Reallocate data give the sorting of the variables
            data = data(locationsT,:);  

            % Add nans where xlsread does not find any data (empty cells 
            % in xls or xlsx spreadsheet) (Only fixes missing data at the 
            % end of the excel spreadsheet, not at the start)
            numOfTypes = size(types,1);
            dim1       = numOfTypes - size(data,1);
            dim2       = size(data,2);
            data       = [data; nan(dim1,dim2)];
            
        end
        
        varargout = getDiff(varargin)
        varargout = locateStrings(varargin)
        varargout = removeDuplicates(varargin)
        
    end
    
end
        
