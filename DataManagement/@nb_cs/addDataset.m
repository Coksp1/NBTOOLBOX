function obj = addDataset(obj,dataset,NameOfDataset,types,variables)
% Syntax:
%
% obj = addDataset(obj,dataset,NameOfDataset,types,variables)
%
% Description:
%
% Makes it possible to add one dataset to a existing nb_cs object
% 
% Caution : If more than one dataset is added to an object the link to the
%           data source is broken!
%
% Input:
% 
% - obj           : An object of class nb_cs
% 
% - dataset       : Either a string with the name of excel
%                   spreadsheet or a .mat file (no extension 
%                   needed), or a numerical matrix.
% 
% - NameOfDataset : Must be a string with the dataset name. If not
%                   given (or given as '') the default name
%                   Database<jj> is given. Where jj is the number 
%                   of added datasets of the object, including 
%                   dataset you add with this method.
% 
% - types         : A cell array of string with the names of the
%                   types you want to add. Only needed when
%                   numerical matrix of data is added to the 
%                   object. Must have the same size as the data you
%                   add.
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
% Examples:
%
% obj = nb_cs;
% obj = obj.addDataset([2,2],'test',{'First'},{'Var1','Var2'});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % obj = addDataset(obj,dataset,NameOfDataset,types,variables)

    if nargin < 5
        variables = {};
        if nargin < 4
            types = '';
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

        if iscellstr(NameOfDataset) && size(NameOfDataset,2) == 1
            NameOfDataset = char(NameOfDataset);
        else
            error([mfilename ':: ''NameOfDataset'' input must be a string with the name of the added dataset.'])
        end

    end

    [dataOfNewDataBase, variablesOfNewDataBase, typesOfNewDataBase, userdata,localVariables] = ...
        nb_cs.dataset2Properties(dataset,types,variables,NameOfDataset,obj.sorted);

    % Assign the userData and localVariables properties
    obj.userData       = userdata;
    obj.localVariables = localVariables;
    
    originalNameOfDataset = NameOfDataset;
    if ischar(dataset)
        NameOfDataset = dataset;
    end
    
    % Test if the data match the lenght of the varibales and types
    % inputs
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
                             int2str(size(variablesOfNewDataBase,2)) ') you are trying to add to the nb_cs object; ' NameOfDataset '(dataset nr. ' int2str(obj.numberOfDatasets + 1) ' of the object)'])
        end
    end

    if size(dataOfNewDataBase,1) ~= size(typesOfNewDataBase,1)
        error([mfilename ':: The data has not the same size (' int2str(size(dataOfNewDataBase,1)) ') as the number of unique types ('...
                         int2str(size(typesOfNewDataBase,1)) ') you are trying to add to the nb_cs object; ' NameOfDataset '(dataset nr. ' int2str(obj.numberOfDatasets + 1) ' of the object)'])
    end    

    % Check if some new types are added or some types are missing 
    % If so we need to expand the added datasets or the existing 
    % correspondingly
    if ~isempty(obj.types)

        % Add nan for all variables in the dataset if it is not
        % included in the first place
        if size(obj.types,1)~=size(typesOfNewDataBase,1)

            [obj, dataOfNewDataBase] = updateData(obj,typesOfNewDataBase,dataOfNewDataBase,'types');

        elseif sum(strcmp(char(obj.types),typesOfNewDataBase)) ~= size(obj.types,1)

            [obj, dataOfNewDataBase] = updateData(obj,typesOfNewDataBase,dataOfNewDataBase,'types');

        end

    else

        obj.types = typesOfNewDataBase;

    end

    % Check if some new variables are added or some variables are 
    % missing. If so we need to expand the added datasets or the 
    % existing correspondingly
    if ~isempty(obj.variables)

        % Add nan for all variables in the dataset if it is not
        % included in the first place
        if size(obj.variables,2)~=size(variablesOfNewDataBase,2)

            [obj, dataOfNewDataBase] = updateData(obj,variablesOfNewDataBase,dataOfNewDataBase,'variables');

        elseif sum(strcmp(char(obj.variables),variablesOfNewDataBase)) ~= size(obj.variables,2)

            [obj, dataOfNewDataBase] = updateData(obj,variablesOfNewDataBase,dataOfNewDataBase,'variables');

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

    if size(obj.types,1) > 1
        obj.types = obj.types';
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
                newSubLink.types      = typesOfNewDataBase;
                newSubLink.data       = obj.data(:,:,obj.numberOfDatasets);
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
