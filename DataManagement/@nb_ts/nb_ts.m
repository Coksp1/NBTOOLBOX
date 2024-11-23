classdef nb_ts < nb_dataSource
% Description:
%
% A class representing timeseries data. 
% 
% Constructor:      
%
%   obj = nb_ts(datasets,NameOfDatasets,startDate,variables)
%   obj = nb_ts(datasets,NameOfDatasets,startDate,variables,sorted)
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
%       - mat     : Name(s) of the .mat files to import. (With or 
%                   without extension.). 
% 
%                   Format of the .mat file:
%                   
%                   The .mat file must be saved structure with the 
%                   fieldnames as the variable names and the fields
%                   as the data of the variables, as doubles. Plus 
%                   it must have a field with name 'startDate' with
%                   the start date of the data, as a string.
%                   
%       - tseries : As an IRIS tseries object.
% 
%       - dyn_ts  : As dyn_ts object(s), each page of the dyn_ts  
%                   object is added as separate datasets.
% 
%       - double  : As double matrix. Each page of the matrix will 
%                   be added as separate datasets.  
% 
%       - struct  : As a structure of either dyn_ts object or  
%                   double matrices. Each field is added as 
%                   separate datasets.
%         
%       - FAME    : A string with the FAME path for where the FAME 
%                   database you want read is. Must include the
%                   extension .db. Not supported by public version.
%
%       - SMART   : Give 'smart'.  Not supported by public version.
%         
%        You can also give a cell array consisting of one or a 
%        combination of the data types mentioned above. Each cell  
%        will be added as a new dataset. 
%     
%        Extra: Use the method structure2nb_ts function to add all  
%               the fields of the structure as variables in an 
%               nb_ts object. (If each field has more page then 1,  
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
%       - tseries : A string with the wanted dataset name. Default 
%                   is 'Dataset1'.
% 
%       - dyn_ts  : A string with the wanted dataset name. Default 
%                   is 'Dataset1'.
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
%       - FAME    : A string with the vintage date to fetch. Default 
%                   is the FAME path name.
%
%       - SMART   : A string with the context date to fetch. Default 
%                   is to fetch last context.
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
%       when numerical data is given through a struct) or when you 
%       fetch data from a FAME database (the start date of the 
%       fetched data).
%         
%       Must be a string on the date format given below or an 
%       object which is of a subclass of the nb_date class.
%
%       Dating convention:
%         > Yearly      : 'yyyy'.           E.g. '2011'
%         > Semiannualy : 'yyyySs'          E.g. '2011S1'
%         > Quarterly   : 'yyyyQq'.         E.g. '2011Q1'
%         > Monthly     : 'yyyyMm(m)'.      E.g. '2011M1', 
%                                                '2011M11'
%         > Weekly      : 'yyyyWw(w)'       E.g. '2011W1'
%         > Daily       : 'yyyyMm(m)Dd(d)'  E.g. '2011M1D1', 
%                                                '2011M11D11'
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
%        > An tseries or an nb_math_ts object. The number of  
%          variables must be of the same as the size of the data 
%          (2. dimension).
%         
%        > When you want to fetch data from a FAME database. I.e. 
%          the variables fetched. 
%
%        > When you give a cell array of one of the types mentioned
%          above.
% 
%   - sorted : true or false. Default is true.
%
%   Output:
% 
%   - obj : An object of class nb_ts
%
%   Examples:
% 
%   - xls(x):
%             
%       One excel spreadsheet
%         
%       obj = nb_ts('test1')
%         
%       More excel spreadsheets
%            
%       obj = nb_ts({'test1','test2',...})
%             
%       same as
%         
%       obj = nb_ts({'test1','test2',...},{'test1','test2',...})
%         
%   - mat:
%         
%   	One .mat file
%         
%       obj = nb_ts('test1')
%         
%       More .mat files
%         
%       obj = nb_ts({'test1','test2',...})
%         
%       same as
%         
%       obj = nb_ts({'test1','test2',...},{'test1','test2',...})
%         
%   - nb_math_ts:
%         
%      One nb_math_ts object
%         
%      obj = nb_ts(test1,'test1','',{'varName1','varName2',...})
%            
%      obj = nb_ts(test1,'','',{'varName1','varName2',...})
%         
%      same as
%         
%      obj = nb_ts(test1,'Database1','',...
%                  {'varName1','varName2',...})
%         
%      More nb_math_ts objects
%         
%      obj = nb_ts({test1,test2,...},{'test1,'test2',...},...
%                   '',{'varName1','varName2',...})
%         
%      obj = nb_ts({test1,test2,...},{},'',...
%                  {'varName1','varName2',...})
%         
%      same as
%         
%      obj = nb_ts({test1,test2,...},...
%                  {'Database1','Database2',...},'',...
%                  {'varName1','varName2',...})
%         
%   - tseries (IRIS:
%         
%      One tseries object
%         
%      obj = nb_ts(test1,'test1','',{'varName1','varName2',...})
%         
%      obj = nb_ts(test1,'','',{'varName1','varName2',...})
%         
%      same as
%         
%      obj = nb_ts(test1,'Database1','',...
%                  {'varName1','varName2',...})
%         
%     More tseries objects
%         
%      obj = nb_ts({test1,test2,...},{'test1,'test2',...},'',...
%                  {'varName1','varName2',...})
%         
%      obj = nb_ts({test1,test2,...},{},'',...
%                  {'varName1','varName2',...})
%         
%      same as
%         
%      obj = nb_ts({test1,test2},{'Database1','Database2'},...
%                  '',{'varName1','varName2',...})
%         
%   - dyn_ts:
%         
%      One dyn_ts object
%         
%      obj = nb_ts(test1,'test1')
%         
%         
%      obj = nb_ts(test1)
%         
%      same as
%         
%      obj = nb_ts(test1,'Database1')
%         
%      More dyn_ts objects
%         
%      obj = nb_ts({test1,test2,...},{'test1,'test2',...})
%         
%      obj = nb_ts({test1,test2,...})
%         
%      same as
%         
%      obj = nb_ts({test1,test2,...},{'Database1','Database2',...})
%         
%   -struct: 
%         
%      One struct
%         
%      > Consisting of dyn_ts object(s):
%         
%         obj = nb_ts(struct1)
%         
%      > Consisting of double matrices:
%         
%         obj = nb_ts(struct1,{},'1994Q1',{'Var1','Var2',...})
%         
%      More structs
%             
%      > Consisting of dyn_ts object(s):
%         
%         obj = nb_ts({struct1,stuct2,...})
%         
%      > Consisting of double matrices:
%         
%         obj = nb_ts({struct1,stuct2,...},{},'1994Q1',...
%                     {'Var1','Var2',...})
%         
%  - double matrix:
%         
%      One matrix
%         
%      obj = nb_ts(double1,'','1994Q1',{'Var1','Var2',...})
%         
%      obj = nb_ts(double1,'test1','1994Q1',{'Var1','Var2',...})
%         
%      More matrices
%  
%      obj = nb_ts({double1,double2,...},{},'1994Q1',...
%                  {'Var1','Var2',...})
%         
%      obj = nb_ts({double1,double2,...},{'name1','name2',...},...
%                  '1994Q1',{'Var1','Var2',...})
%         
%      One matrix with more pages:
%         
%      obj = nb_ts(double1,{},'1994Q1',{'Var1','Var2',...})
%         
%      obj = nb_ts(double1,{'name1','name2',...},'1994Q1',...
%                  {'Var1','Var2',...})
%         
% See also: 
% nb_date, nb_year, nb_semiAnnual, nb_quarter, nb_month, nb_day,
% nb_math_ts, nb_cs, nb_graph_ts
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected,Dependent=true)
        
        % Number of observation of the data stored in the object. As a 
        % double.
        numberOfObservations;    
        
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
        % 365 : daily (Also when dealing with business days, 
        %       which gets nan values for all the skipped days)
        frequency               = [];            
        
        % The start date of the data. Given as an object which is of a 
        % subclass of the nb_date class. Either: nb_day, nb_week, nb_month, 
        % nb_quarter, nb_semiAnnual or nb_year.
        startDate               = nb_date;
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function obj = nb_ts(datasets,NameOfDatasets,startDate,variables,sorted)
        % Constructor      
        
            if nargin < 5
                sorted = true;
                if nargin < 4
                    variables = {};
                    if nargin < 3
                        startDate = '';
                        if nargin < 2
                            NameOfDatasets = {};
                            if nargin < 1
                               datasets = {}; 
                            end
                        end
                    end
                end
            end
            
            obj        = obj@nb_dataSource();
            obj.sorted = sorted;
            
            if ~isempty(datasets)
                
                if isnumeric(datasets) || islogical(datasets) || isa(datasets,'nb_distribution')
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                    if nargin < 4
                        variables = nb_appendIndexes('Var',1:size(datasets,2))';
                    end
                    
                    try
                        obj = addDataset(obj,datasets,NameOfDatasets,startDate,variables);
                    catch Err
                        
                        if ~iscellstr(NameOfDatasets)
                            rethrow(Err);
                        end
                        
                        if size(datasets,3) == length(NameOfDatasets)  
                            obj           = addDataset(obj,datasets,'',startDate,variables);
                            obj.dataNames = nb_rowVector(NameOfDatasets);
                        else
                            rethrow(Err);
                        end
                                 
                    end
                    
                elseif ischar(datasets) || isa(datasets,'dyn_ts') || isa(datasets,'tseries') || isa(datasets,'ts') || isa(datasets,'nb_math_ts')
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                    if nargin < 4
                        if isa(datasets,'nb_math_ts')
                            variables = nb_appendIndexes('Var',1:size(datasets,2))';
                        end
                    end
                    obj = addDataset(obj,datasets,NameOfDatasets,startDate,variables);
                    
                elseif isstruct(datasets)
                    
                    datasets = {datasets};
                    
                    obj = addDatasets(obj,datasets,{},startDate,variables);
                    
                elseif isa(datasets,'DataPackage.TS')
                    try
                        obj = nb_javaTS2nb_ts(datasets,sorted);
                    catch Err
                        if ~exist('nb_javaTS2nb_ts','file')
                            error('You need to have access to SMART.')
                        else
                            rethrow(Err)
                        end
                    end
                else
                    try
                        obj = addDatasets(obj,datasets,NameOfDatasets,startDate,variables);
                    catch Err
                        
                        if iscell(datasets)
                            rethrow(Err)
                        else
                            
                            if strcmp(Err.identifier,'nb_ts:addDatasets:inputMustBeACell')
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
    % Methods not saved in seperate files
    %======================================================================
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
        % Written by Kenneth S. Paulsen   
            
            oldObj = obj;
            
            if notHandleNaN
                
                switch lower(outputType)
                    case 'nb_ts'
                        
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
                        
                    case {'double','nb_ts_scalar'}
                        
                        values = func(obj.data,extraInp{:},dimension);
                        if strcmpi(outputType,'double')
                            obj = values;
                        else

                            switch dimension
                                case 1
                                    error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''' outputType '''.'])
                                case 2
                                    obj = nb_ts(values,obj.dataNames,obj.startDate,{func2str(func)},obj.sorted);
                                case 3
                                    obj = nb_ts(values,func2str(func),obj.startDate,obj.variables,obj.sorted);
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

                case 'nb_ts'

                    switch dimension

                        case 1

                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfDatasets
                                    isNotNan = ~isnan(obj.data(:,ii,jj));
                                    if any(isNotNan)
                                        inp                      = [{obj.data(isNotNan,ii,jj)},extraInp];
                                        obj.data(isNotNan,ii,jj) = func(inp{:});
                                    end
                                end
                            end

                        case 2

                            for ii = 1:obj.numberOfDatasets
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(obj.data(jj,:,ii));
                                    if any(isNotNan)
                                        inp                      = [{obj.data(jj,isNotNan,ii)},extraInp];
                                        obj.data(jj,isNotNan,ii) = func(inp{:});
                                    end
                                end
                            end

                        case 3

                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(obj.data(jj,ii,:));
                                    if any(isNotNan)
                                        inp                      = [{obj.data(jj,ii,isNotNan)},extraInp,{3}];
                                        obj.data(jj,ii,isNotNan) = func(inp{:});
                                    end
                                end
                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) '.'])

                    end

                case {'double','nb_ts_scalar'}

                    switch dimension

                        case 1

                            values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfDatasets
                                    isNotNan = ~isnan(obj.data(:,ii,jj));
                                    if any(isNotNan)
                                        inp             = [{obj.data(isNotNan,ii,jj)},extraInp];
                                        values(1,ii,jj) = func(inp{:});
                                    end
                                end
                            end

                        case 2

                            values = nan(obj.numberOfObservations,1,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfDatasets
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(obj.data(jj,:,ii));
                                    if any(isNotNan)
                                        inp             = [{obj.data(jj,isNotNan,ii)},extraInp];
                                        values(jj,1,ii) = func(inp{:});
                                    end
                                end
                            end

                        case 3

                            values = nan(obj.numberOfObservations,obj.numberOfVariables,1);
                            for ii = 1:obj.numberOfVariables
                                for jj = 1:obj.numberOfObservations
                                    isNotNan = ~isnan(obj.data(jj,ii,:));
                                    if any(isNotNan)
                                        inp             = [{obj.data(jj,ii,isNotNan)},extraInp,{3}];
                                        values(jj,ii,1) = func(inp{:});
                                    end
                                end
                            end

                        otherwise
                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) '.'])   
                    end
                    
                    if strcmpi(outputType,'double')
                        obj = values;
                    else
                        
                        switch dimension
                            case 1
                                error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output i set to ''' outputType '''.'])
                            case 2
                                obj = nb_ts(values,obj.dataNames,obj.startDate,{func2str(func)},obj.sorted);
                            case 3
                                obj = nb_ts(values,func2str(func),obj.startDate,obj.variables,obj.sorted);
                        end
                        
                    end
                    
                case 'nb_cs'

                    switch dimension
                        case 1   
                        otherwise  
                            error([mfilename ':: Cannot take the ' func2str(func) ' over the '  int2str(dimension) ', when the demanded output is set to ''nb_cs''.'])     
                    end

                    values = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                    for ii = 1:obj.numberOfVariables
                        for jj = 1:obj.numberOfDatasets
                            isNotNan = ~isnan(obj.data(:,ii,jj));
                            if any(isNotNan)
                                inp             = [{obj.data(isNotNan,ii,jj)},extraInp];
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
                if strcmpi(outputType,'nb_ts')

                    obj = obj.addOperation(func,[extraInp, {outputType,dimension}]);

                elseif strcmpi(outputType,'nb_cs') || strcmpi(outputType,'nb_ts_scalar')

                    oldObj = oldObj.addOperation(func,[extraInp,{outputType,dimension}]);
                    linksT = oldObj.links;
                    obj    = obj.setLinks(linksT);

                end

            end
            
        end
        
        varargout = getWindow(varargin)
        
        varargout = checkInverseMethodsInput(varargin)
        
    end
    
    %==============================================================
    % Protected static methods of this class
    %==============================================================
    methods (Static=true, Access=protected, Hidden=true)
         
        function [data, variables, startDate, endDate, frequency, userData,localVariables] = dataset2Properties(dataset,startDate,var,vintage,sorted)
        % Description:
        %
        % A static method of the nb_ts class 
        %
        % Load properties (data) from .xls file, .mat file, dyn_ts object,
        % tseries object, nb_math_ts object or a FAME database
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

                if isempty(startDate)
                    warning(['Start date of data is not given, ''1994Q1'' is default. '...
                             '(This is only important if the data is given from a double/logical matrix)']) %
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
                    tempData     = dataset;
                    notSortedVar = strtrim(cellstr(var));

                    if size(notSortedVar,2)==1
                        notSortedVar =  notSortedVar'; 
                    end

                    variables = nb_ts.removeDuplicates(sort(notSortedVar));                
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
                    else
                        data = nan(size(tempData));
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

                    periods = size(data,1);
                    endDate = startDate + periods - 1;

                end

            elseif ischar(dataset)

                if nb_contains(dataset,'.db')
                    try
                        [data, variables, startDate, endDate, frequency] = ...
                            nb_fame2Properties(strrep(dataset,'.db',''), var, ...
                            startDate, vintage, sorted);
                    catch Err
                        if ~exist('nb_fame2Properties','file')
                            error('You need to have access to FAME functionalities to fetch data from FAME.')
                        else
                            rethrow(Err)
                        end
                    end
                    return
                elseif strcmpi(dataset,'smart')
                    try
                        [data, variables, startDate, endDate, frequency, userData] = ...
                            nb_smart2Properties(var, startDate, vintage, sorted);
                    catch Err
                        if ~exist('nb_smart2Properties','file')
                            error('You need to have access to SMART functionalities to fetch data from SMART.')
                        else
                            rethrow(Err)
                        end
                    end
                    return
                end
                
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
                        [data, variables, startDate, endDate, frequency] = nb_ts.xls2Properties([dataset '.xlsx'],sheet,sorted);
                        
                    case 'xlsm'
                        
                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency] = nb_ts.xls2Properties([dataset '.xlsm'],sheet,sorted);
                        
                    case 'csv'
                        
                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency] = nb_ts.xls2Properties([dataset '.csv'],sheet,sorted);
                        
                    case 'mat'

                        temp = load(dataset);
                        [data, variables, startDate, endDate, frequency, userData,localVariables] = nb_ts.structure2Properties(temp,'',sorted); % Here we assume that the startDate are the same for all databases
                        
                    case 'xls'

                        sheet = vintage;
                        [data, variables, startDate, endDate, frequency] = nb_ts.xls2Properties(dataset,sheet,sorted);

                    case 'splittedxls'

                        try % Test if the output is saved to two seperate xls spreadsheets, if they are load them up and collect properties

                            [data1, variables1, startDate, endDate, frequency] = nb_ts.xls2Properties([dataset '_ModelVars'],'',sorted);
                            [data2, variables2, ~, ~, ~]                       = nb_ts.xls2Properties([dataset '_TransVars'],'',sorted);

                            variables              = sort([variables1 variables2]);
                            [~,variablesNotInNew]  = nb_ts.getDiffVariables(variables2,variables);
                            indexNotInNewVariables = nb_findIndex(variablesNotInNew,variables);

                            if ~isempty(indexNotInNewVariables)

                                sizeOldData = [size(data1,1), size(data1,2)+size(data2,2)];
                                transData   = nan(sizeOldData(1),sizeOldData(2));
                                for kk = 1:sizeOldData(2)
                                    fin = sum(indexNotInNewVariables==kk);
                                    if fin
                                        indexVar          = strcmp(variables{kk},variables1);
                                        transData(:,kk,:) = data1(:,indexVar);
                                    else
                                        indexVar          = strcmp(variables{kk},variables2);
                                        transData(:,kk,:) = data2(:,indexVar);
                                    end
                                end
                                data = transData;

                            end

                        catch Err4
                            error(['Did not find; ' dataset ', ' dataset '.xlsx, ' dataset '.xls or ' dataset '.mat in the current folder.']);
                        end

                end

            elseif isa(dataset,'nb_math_ts')

                tempData  = double(dataset);
                frequency = dataset.startDate.frequency;
                startDate = dataset.startDate;
                endDate   = dataset.endDate;
                
                % Sort the variables and data
                notSortedVar = strtrim(cellstr(var));
                if size(notSortedVar,2)==1
                    notSortedVar =  notSortedVar'; 
                end

                variables = nb_ts.removeDuplicates(sort(notSortedVar));                
                if size(variables,2) == size(tempData,2) % Just to make it to the error message in addDataset method instead

                    if sorted % Reallocate given that the variables is sorted
                        [~,loc] = ismember(variables,notSortedVar);
                        data    = tempData(:,loc,:);
                    else
                        variables = notSortedVar;
                        data      = tempData;
                    end
                    
                else
                    data = nan(size(tempData));
                end   

            elseif isa(dataset,'tseries')

                tempData  = double(dataset);
                try
                    frequency = get(dataset,'freq');
                catch Err
                    try
                        frequency = dataset.freq;
                    catch
                        rethrow(Err);
                    end
                end
                if isa(frequency,'Frequency')
                    % Newer versions of IRIS uses the Frequency class
                    % instead of scalar integer!
                    frequency = double(frequency);
                end
                try
                    startDate = get(dataset,'start');
                    endDate   = get(dataset,'end');
                catch Err
                    try
                        startDate = dataset.start;
                        endDate   = dataset.end;
                    catch
                        rethrow(Err);
                    end
                end
                startDate = dat2str(startDate);
                startDate = startDate{1};
                endDate   = dat2str(endDate);
                endDate   = endDate{1};
                
                % Sort the variables and data
                notSortedVar = strtrim(cellstr(var));
                if size(notSortedVar,2)==1
                    notSortedVar =  notSortedVar'; 
                end

                variables = nb_ts.removeDuplicates(sort(notSortedVar));                               
                if size(variables,2) == size(tempData,2) % Just to make it to the error message in addDataset method instead

                    if sorted % Reallocate given that the variables is sorted
                        [~,loc] = ismember(variables,notSortedVar);
                        data    = tempData(:,loc,:);
                    else
                        variables = notSortedVar;
                        data      = tempData;
                    end
                    
                else
                    data = nan(size(tempData));
                end

            elseif isa(dataset,'dyn_ts')

                data      = cell2mat(dataset.data(2:end,2:end,:));
                variables = dataset.data(1,2:end,1);
                frequency = dataset.frequency;
                switch frequency   
                    case 1
                        startDate = nb_year(dataset.start);
                        endDate   = nb_year(dataset.finish);
                    case 4                       
                        startDate = nb_quarter(dataset.start);
                        endDate   = nb_quarter(dataset.finish);
                    case 12
                        startDate = nb_month(dataset.start);
                        endDate   = nb_month(dataset.finish);
                end
                
            elseif isa(dataset,'ts')
                
                data      = dataset.data;
                variables = dataset.varnames;
                if sorted % Reallocate given that the variables is sorted
                    [variables,ind] = sort(variables);
                    data            = data(:,ind,:);
                end
                frequency = dataset.frequency;
                switch frequency   
                    case ''
                        startDate = nb_year(dataset.start);
                        endDate   = nb_year(dataset.finish);
                    case 'H'
                        startDate = nb_semiAnnual(dataset.start);
                        endDate   = nb_semiAnnual(dataset.finish);
                    case 'Q'                       
                        startDate = nb_quarter(dataset.start);
                        endDate   = nb_quarter(dataset.finish);
                    case 'M'
                        startDate = nb_month(dataset.start);
                        endDate   = nb_month(dataset.finish);
                    case 'W'
                        startDate = nb_week(dataset.start);
                        endDate   = nb_week(dataset.finish);
                    otherwise
                        startDate = nb_year(dataset.start);
                        endDate   = nb_year(dataset.finish);
                        
                end
                
                frequency = startDate.frequency;

            else
                error([mfilename ':: Dataset is not a dyn_ts object, a string with name of mat file or xls file or a double matrix with data (variables must then be given).'])
            end

        end
        
        function [data, variables, startDate, endDate, frequency, userData,localVariables] = structure2Properties(structure,startDate,sorted)
        % Syntax:
        %
        % [data, variables, startDate, endDate, frequency] = ...
        %  nb_ts.structure2Properties(structure,startDate)
        %
        % Description:
        %
        % Static method of the nb_ts class
        % 
        % Load properties from a structure of double vectors
        %
        % Written by Kenneth S. Paulsen

            if nargin < 2
                startDate = '';
            end
        
            if isfield(structure,'variables')
                [data, variables, startDate, endDate, frequency, userData,localVariables] = nb_ts.structure2PropertiesNew(structure,startDate,sorted);
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
        
        function [data, variables, startDate, endDate, frequency, userData,localVariables] = structure2PropertiesNew(structure,startDate,sorted)
        % Syntax:
        %
        % [data, variables, startDate, endDate, frequency] = ...
        %  nb_ts.structure2Properties(structure,startDate)
        %
        % Description:
        %
        % Static method of the nb_ts class
        % 
        % Load properties from a structure of double vectors
        %
        % Written by Kenneth S. Paulsen

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
            data = nan(r,length(variables),p);
            for j = 1:size(variablesTemp,2)
                data(:,j,:) = structure.(['Var' int2str(j)]);
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
        
        function [data, variables, startDate, endDate, frequency] = xls2Properties(xls,sheet,sorted)
        % Description:
        %
        % Static method of the nb_ts class 
        %
        % Load from excel spreadsheet to properties of nb_ts
        %
        % Written by Kenneth S. Paulsen
        
            c   = nb_xlsread(xls,sheet);
            obj = nb_cell2obj(c,true,sorted);
            if ~isa(obj,'nb_ts')
                error([mfilename ':: Cannot convert the data of the file ' xls ' to time-series.'])
            end
            data      = obj.data;
            variables = obj.variables;
            startDate = obj.startDate;
            endDate   = obj.endDate;
            frequency = obj.startDate.frequency;
       
        end
        
    end
    
    %==============================================================
    % Static methods of this class
    %==============================================================
    methods (Static=true)
        
        function obj = loadobj(s)
            obj = nb_ts.unstruct(s);
        end
        
        varargout = rand(varargin)
        varargout = nan(varargin)
        varargout = ones(varargin)
        varargout = zeros(varargin)
        varargout = unstruct(varargin)
        varargout = fromRise_ts(varargin)
        varargout = simulate(varargin)

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
                    error([mfilename,':: the start and the end dates of the two datasets must be the same'])
                case 2
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 3
                    error([mfilename,':: the variables of the two datasets must be the same'])
                case 4
                    error([mfilename,':: the datasets must have the same number of pages'])
            end
            
        end
        
        function [data, variables, startDate, endDate, frequency] = interpretXlsOutput(data,variables,dates)
            
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
                    [~,locations] = ismember(dates,allDates);
                catch %#ok<CTCH>
                   error([mfilename ':: Some time periods are missing, but can''t figure out how...']) 
                end
                tempData          = data;
                data              = nan(periods + 1,size(data,2));
                data(locations,:) = tempData;

            end
            
        end
        
        varargout = findIndexesOfDates(varargin)
        varargout = getDiff(varargin)
        varargout = locateVariables(varargin)
        varargout = removeDuplicates(varargin)
        
    end
    
end
