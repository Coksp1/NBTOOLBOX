classdef nb_cell < nb_dataSource
% Description:
%
% A class for storing data from cell (May be linked to an excel 
% spreadsheet). 
%    
% Constructor:      
%
%   obj = nb_cell(datasets,NameOfDatasets)
%   obj = nb_cell(datasets,NameOfDatasets)
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
%                           want the object to be updateable
%                           you must provide the extension.
% 
%      - cell   : As a cell matrix. Each page of the matrix will 
%                 be added as separate datasets.  
%
%      You can also give a cellstr array consisting of more excel 
%      file names. Each excel file will be added as a new dataset.
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
%      - cell   : A string with the wanted dataset name. Default 
%                 is 'Dataset1'.  
%
%                 Caution: When you given cell matrices which 
%                          has more pages then one. Each of 
%                          the pages will be added as a dataset. 
%                          The name of this datasets will, if the 
%                          input NameOfDatasets has the same size 
%                          as the input datasets, get the name 
%                          NameOfDatasets{jj}, where jj is 
%                          the page number, or else get the name 
%                          'Database<jj>'. 
%
%       - A cellstr array of excel spreadsheet:
% 
%        If you give a cellstr array to the datasets input, this input 
%        must be a cell array of strings. If you give a cellstr array 
%        which doesn't have the same size as the cellstr array given 
%        to the datasets input, the datasets which is left gets the 
%        name 'Database<jj>', where <jj> stands for this added 
%        datasets number.
% 
%        If you give an empty cell array, i.e. {} all the datasets 
%        get the names given by a cellstr with the excel file names.
%         
%   Output:
% 
%   - obj      : An object of class nb_cell.
% 
%   Examples:
% 
%   - xls(x):
%             
%      One excel spreadsheet
%         
%      obj = nb_cell('test1')
%         
%      More excel spreadsheets
%            
%      obj = nb_cell({'test1','test2',...})
%             
%      same as
%         
%      obj = nb_cell({'test1','test2',...},{'test1','test2',...})
%          
%   - cell matrix:
%         
%      One matrix
%         
%      obj = nb_cell(cell1)
%         
%      obj = nb_cell(cell1,'test1')
%           
%      One matrix with more pages:
%         
%      obj = nb_cell(cell1,{})
%         
%      obj = nb_cell(cell1,{'name1','name2',...})
% 
% See also: 
% nb_table_cell
% 
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
        
        % The data of the object as cell
        cdata                   = {};  
        
    end

    properties (Hidden=true)
        
        % The data of the object as cell with numerical values not updated!
        c                       = {};  
        
    end
    
    %{
    -----------------------------------------------------------------------
    Accessible methods
    -----------------------------------------------------------------------
    %}
    methods

        function obj = nb_cell(datasets,NameOfDatasets)
        % Constructor:      
        %
        % Written by Kenneth Sæterhagen Paulsen
            
            if nargin < 2
                NameOfDatasets = {};
                if nargin < 1
                   datasets = {}; 
                end
            end
            
            obj        = obj@nb_dataSource;
            obj.sorted = false;
            
            if ~isempty(datasets)
                
                if iscellstr(datasets) && isrow(datasets)
                
                    obj = addDatasets(obj,datasets,NameOfDatasets);
                    
                elseif iscell(datasets)
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                   
                    try
                        obj = addDataset(obj,datasets,NameOfDatasets);
                    catch Err
                        
                        if ~iscellstr(NameOfDatasets)
                            rethrow(Err);
                        end
                        
                        if size(datasets,3) == size(NameOfDatasets,2)
                            obj           = addDataset(obj,datasets,'');
                            obj.dataNames = NameOfDatasets;
                        else
                            rethrow(Err);
                        end
                                 
                    end
                    
                elseif ischar(datasets) 
                    
                    if isempty(NameOfDatasets)
                        NameOfDatasets = '';
                    end
                    obj = addDataset(obj,datasets,NameOfDatasets);
                    
                else
                    
                    error([mfilename ':: Wrong input datasets.'])
                
                end
                
            end
            
        end
        
        function propertyValue = get.cdata(obj)
            
            ind                = cellfun(@(x)isa(x,'numeric'),obj.c);
            propertyValue      = obj.c;
            propertyValue(ind) = num2cell(obj.data(ind));
            
        end
        
        % Overload nb_dataSource methods
            
    end
    
    %{
    -----------------------------------------------------------------------
    Accessible methods which are in seperate files
    -----------------------------------------------------------------------
    %}
    methods (Access=public,Hidden=true)
        
        function n = numArgumentsFromSubscript(obj,~,~)
            n = numel(obj);
        end
        
        function ind = end(obj,k,~)
            ind = size(obj.c,k);
        end
        
    end
    
    %{
    -----------------------------------------------------------------------
    Protected methods
    -----------------------------------------------------------------------
    %}
    methods (Access=protected)
        
        function obj = evalStatOperator(obj,func,outputType,dimension,extraInp)
            
            oldObj = obj;
            
            % I cannot vectorize here because the function mean made by
            % matlab does not handle nan values as wanted.
            switch lower(outputType)

                case 'nb_cell'

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

                case 'double'

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
                                    values(ii,1,jj) = func(inp{:});

                                end

                            end

                        case 3

                            values = nan(obj.numberOfTypes,1,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfVariables

                                for jj = 1:obj.numberOfTypes

                                    isNotNan        = ~isnan(obj.data(jj,ii,:));
                                    inp             = {obj.data(jj,ii,isNotNan)};
                                    inp             = [inp,extraInp]; %#ok<AGROW>
                                    values(ii,jj,1) = func(inp{:});

                                end

                            end

                        otherwise

                            error([mfilename ':: Cannot take the ' func2str(func) ' over the dimension '  int2str(dimension) '.'])

                    end

                    obj = values;

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
        
        function [data, userData, localVariables] = dataset2Properties(dataset,sheet)
        % Description:
        %
        % Static method
        % 
        % Load properties (data) from xls or cell matrices
        % 
        % Written by Kenneth S. Paulsen

            userData       = '';
            localVariables = [];

            if ischar(dataset)

                locfold = nb_contains(dataset,'\');
                if locfold
                    num           = strfind(dataset,'\');
                    FolderName    = dataset(1:num(end)-1);
                    dataset       = dataset(num(end)+1:end);
                    OldFolderName = cd(FolderName);
                end

                % Decide which type of file we are trying to load
                dotIndex = strfind(dataset,'.');
                if ~isempty(dotIndex)
                    type    = dataset(dotIndex(1) + 1:end);
                    dataset = dataset(1:dotIndex(1)-1);
                else
                    if exist([dataset '.xlsx'],'file') == 2
                        type = 'xlsx';
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
                                    type = '';
                                end
                            end
                        end
                    end
                end

                switch type

                    case 'xlsx'

                        data = nb_cell.xls2Properties([dataset '.xlsx'],sheet);

                    case 'xlsm'
                        
                        data = nb_cell.xls2Properties([dataset '.xlsm'],sheet);    
                      
                    case 'csv'
                        
                        data = nb_cell.xls2Properties([dataset '.csv'],sheet);    
                        
                    case 'xls'

                        data = nb_cell.xls2Properties(dataset,sheet);

                    otherwise

                        error(['Did not find; ' dataset ', ' dataset '.xlsx, ' dataset '.xls or ' dataset '.xlsm in the current folder.']);


                end

                if locfold
                    cd(OldFolderName)
                end

            elseif iscell(dataset)

                if isempty(dataset)

                    % Return these values to get a good error message
                    data      = [];

                else

                    data = dataset;
                    
                end

            else
                error([mfilename ':: Dataset is not a string with name of xls(x) file or a cell matrix with data.'])
            end

        end
        
        function [data, userData, localVariables] = structure2Properties(structure)
        % Description:
        %
        % Static method
        % 
        % Load from mat file to properties of nb_cell
        % 
        % Written by Kenneth S. Paulsen

            if isfield(structure,'localVariables')
                localVariables = structure.localVariables;
            else
                localVariables = [];
            end
       
            if isfield(structure,'userData')
                userData = structure.userData;
            else
                userData = [];
            end
            
            % Load the data from the structure
            data = structure.data;
            
        end
        
        function data = xls2Properties(xls,sheet)
        % Syntax:
        %
        % data = xls2Properties(xls)
        %
        % Description:
        %
        % Static method
        % 
        % Load dataset from excel spreadsheet to properties of the nb_cell 
        % object
        %
        % Written by Kenneth S. Paulsen

            data = nb_xlsread(xls,sheet);
               
        end
        
    end
        
    %{
    -----------------------------------------------------------------------
    Static methods
    -----------------------------------------------------------------------
    %}
    methods (Static=true)
        
        function obj = loadobj(s)  
            obj = nb_cell.unstruct(s);
        end
        
        varargout = rand(varargin)
        varargout = ones(varargin)
        varargout = nan(varargin)
        varargout = unstruct(varargin)
        
    end
    
    %{
    -----------------------------------------------------------------------
    Static methods
    -----------------------------------------------------------------------
    %}
    methods (Static=true,Hidden=true)
        
        function data = interpretXlsOutput(data)
            
        end
        
    end
    
end
        
