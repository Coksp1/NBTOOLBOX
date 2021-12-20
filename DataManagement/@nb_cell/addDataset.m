function obj = addDataset(obj,dataset,NameOfDataset)
% Syntax:
%
% obj = addDataset(obj,dataset,NameOfDataset)
%
% Description:
%
% Makes it possible to add one dataset to a existing nb_cell object
% 
% Caution : If more than one dataset is added to an object the link to the
%           data source is broken!
%
% Input:
% 
% - obj           : An object of class nb_cell
% 
% - dataset       : Either a string with the name of excel
%                   spreadsheet or a cell matrix.
% 
% - NameOfDataset : Must be a string with the dataset name. If not
%                   given (or given as '') the default name
%                   Database<jj> is given. Where jj is the number 
%                   of added datasets of the object, including 
%                   dataset you add with this method.
%                    
% Output:
% 
% - obj : The object itself with the added dataset.
% 
% Examples:
%
% obj = nb_cell;
% obj = obj.addDataset([2,2],'test',{'First'},{'Var1','Var2'});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        NameOfDataset = '';
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

    [dataOfNewDataBase,userdata,localVariables] = nb_cell.dataset2Properties(dataset,NameOfDataset);

    % Assign the userData and localVariables properties
    obj.userData       = userdata;
    obj.localVariables = localVariables;
    
    originalNameOfDataset = NameOfDataset;
    if ischar(dataset)
        NameOfDataset = dataset;
    end
    
    % Add the data of the new dataset
    dim3 = size(dataOfNewDataBase,3);
    if ~isempty(obj.data)

        [r1,c1,p1] = size(obj.data);
        [r2,c2,p2] = size(dataOfNewDataBase);
        rm         = max(r1,r2);
        cm         = max(c1,c2);
        newData    = nan(rm,cm,p1+p2);
        newCData   = cell(rm,cm,p1+p2);
        
        % Assign data property
        newData(1:r1,1:c1,1:p1)  = obj.data;
        newData2                 = newData(1:r2,1:c2,p1:p2);
        ind                      = cellfun(@(x)isa(x,'numeric'),dataOfNewDataBase);
        newData2(ind)            = cell2mat(dataOfNewDataBase(ind));
        newData(1:r2,1:c2,p1:p2) = newData2;
        obj.data                 = newData;
        
        % Assign cell property
        newCData(1:r1,1:c1,1:p1)  = obj.c;
        newCData(1:r2,1:c2,p1:p2) = dataOfNewDataBase;
        obj.c                     = newCData;
        

    else

        newData      = nan(size(dataOfNewDataBase));
        ind          = cellfun(@(x)isa(x,'numeric'),dataOfNewDataBase);
        newData(ind) = cell2mat(dataOfNewDataBase(ind));
        obj.data     = newData;   
        obj.c        = dataOfNewDataBase;
        
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

                otherwise
                    error([mfilename ':: Unsupported extension ' ext])

            end
            
            if createLink
                
                newSubLink            = nb_createDefaultLink();
                newSubLink.source     = source;
                newSubLink.sourceType = sourceType;
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
