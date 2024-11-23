function obj = merge(obj,DB)
% Syntax:
%
% obj = merge(obj,DB)
%
% Description:
%
% Merge another nb_bd object with the current one
% 
% Input:
% 
% - obj : An object of class nb_bd
% 
% - DB  : An object of class nb_bd
% 
% Output:
% 
% - obj : An object of class nb_bd where the datasets from the DB  
%         object are merged with the data of the obj object.
% 
%         Caution: 
% 
%         > It is possible to merge datasets with the same
%           variables as long as they are representing the same 
%           data or have different types.
% 
%         > If the datsets has different number of datasets and one
%           of the merged objects only consists of one, this object
%           will add as many datasets as needed (copies of the 
%           first dataset) so they can merge.
%
%         > It is not possible to merge two bd objects of different 
%           frequencies. Use nb_ts instead.
% 
% Examples:
% 
% obj = nb_bd([2,2; 2,2],'test','2000Q1',{'Var1','Var2'});
% DB  = nb_bd([2,1; 2,2],'test','2000Q2',{'Var1','Var3'});
% obj = obj.merge(DB)
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_bd') || ~isa(DB,'nb_bd')
        error([mfilename ':: The two merged objects must both be of class nb_bd.'])
    end
    
    if obj.frequency ~= DB.frequency
        error([mfilename ':: Merging two time-series with different frequencies are not possible.'])
    end

    % Start the merging
    %--------------------------------------------------------------
    if isempty(obj)
        obj = DB;
    elseif isempty(DB)
        % Do nothing
    else

        if ~obj.isBeingUpdated 
            
            % If the objects are updatable we need merge things also
            % for the property links 
            if ~isUpdateable(obj)
                startDateObj = obj.startDate;
                variablesObj = obj.variables;
                dataObj      = obj.data;
                locationsObj = obj.locations;
                indicatorObj = obj.indicator;
                ignorenanObj = obj.ignorenan;
            end

            if ~isUpdateable(DB)
                startDateDB = obj.startDate;
                variablesDB = obj.variables;
                dataDB      = obj.data;
                locationsDB = obj.locations;
                indicatorDB = obj.indicator;
                ignorenanDB = obj.ignorenan;
            end
            
            if ~obj.isUpdateable() && DB.isUpdateable()

                obj.links              = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataObj;
                tempSubLink.sourceType = 'private(nb_bd)';
                tempSubLink.variables  = variablesObj;
                tempSubLink.startDate  = startDateObj;
                tempSubLink.locations  = locationsObj;
                tempSubLink.indicator  = indicatorObj;
                tempSubLink.ignorenan  = ignorenanObj;
                obj.links.subLinks     = tempSubLink;
                obj.updateable         = 1;  

            elseif obj.isUpdateable() && ~DB.isUpdateable()

                DB.links               = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataDB;
                tempSubLink.sourceType = 'private(nb_bd)';
                tempSubLink.variables  = variablesDB;
                tempSubLink.startDate  = startDateDB;
                tempSubLink.locations  = locationsDB;
                tempSubLink.indicator  = indicatorDB;
                tempSubLink.ignorenan  = ignorenanDB;
                DB.links.subLinks      = tempSubLink;
                DB.updateable          = 1;

            end
            
        end
            
        % If the object is being merged we don't want the following
        % methods to be added to the operation list
        obj.isBeingMerged = 1;
        DB.isBeingMerged  = 1;

        % Test if the databases has the same number of datasets. If one
        % of the datasets has more then one page and the other has only
        % one this function makes copies of the one dataset and make
        % the database have the same number of datasets as the other
        % one. (Same number of pages)
        if obj.numberOfDatasets ~= DB.numberOfDatasets

           if obj.numberOfDatasets < DB.numberOfDatasets
               obj = obj.addPageCopies(DB.numberOfDatasets - obj.numberOfDatasets);
           else
               DB = DB.addPageCopies(obj.numberOfDatasets - DB.numberOfDatasets);
           end

        end
        
        % Merge the dates and expand the data of both databases
        obj = obj.expand(DB.startDate,DB.endDate,'off');
        DB  = DB.expand(obj.startDate,obj.endDate,'off');      
        
        % Finished with the external methods
        obj.isBeingMerged = 0;

        % Merge the variables
        oldVariables = obj.variables;
        if obj.sorted
            obj.variables = nb_bd.removeDuplicates(sort([obj.variables DB.variables]));
        else
            ind           = ismember(DB.variables,obj.variables);
            obj.variables = [obj.variables, DB.variables(~ind)];
        end

        % Merge the location / data information
       
        % Need to expand because we need to make sure that both location
        % and the actual data points matches
        objFullData = getFullRep(obj);
        DBFullData  = getFullRep(DB);
        
        tempData = nan(length(objFullData), length(obj.variables) * obj.numberOfDatasets);
        
        for ii = 1:length(obj.variables)
            
            foundOld = find(strcmp(obj.variables{ii}, oldVariables),1);
            foundNew = find(strcmp(obj.variables{ii}, DB.variables),1);
            if ~isempty(foundOld) && ~isempty(foundNew)
                tempData(:,ii,:) = resolveConflictOfData(objFullData(:,foundOld,:), DBFullData(:,foundNew,:), obj.variables{ii});
            elseif ~isempty(foundNew)
                tempData(:,ii,:) = DBFullData(:,foundNew);
            else
                tempData(:,ii,:) = objFullData(:,foundOld);
            end

        end

        % Find most efficient way to store the merged data
        nanInd   = isnan(tempData);
        numNans  = sum(nanInd,'all'); % number of missing values
        
        if numNans > 0.5 * numel(tempData)
            % Then we want to store locations of where we have values
            obj.indicator = 1;
            obj.locations = sparse(~nanInd);
        else
           obj.indicator = 0;
           obj.locations = sparse(nanInd);
        end    
        obj.data     = tempData(~nanInd);
        
        if obj.isUpdateable() && DB.isUpdateable()
            obj = mergeLinks(obj,DB);
        end

    end

end

% Subfunction which try to find out if it is possible to merge
% to data series of the same variable (which was included in 
% both datasets)
function dataOut = resolveConflictOfData(data1, data2, variableName)

    if ~isa(data1,class(data2))
        error([mfilename ':: The data of the two object must be of the same class. Is of class ' class(data1) ' and ' class(data2)])
    end
    if isa(data1,'nb_distribution') 

        if size(data1,3) > 1
            error([mfilename ':: Cannot merge objects with more than one page when the data is of class nb_distribution.'])
        end
        names1 = {data1.name};
        names2 = {data2.name};
        test   = ismember(names1,names2);
        test1  = strcmpi(names1,'constant(NaN)');
        test2  = strcmpi(names2,'constant(NaN)');
        test   = test | test1 | test2;
        if any(~test)
            error([mfilename,':: Too big discrepancies in the distributions for variable ''' variableName ''', which was found in both dataset.'])
        end
        dataOut(size(data1,1),1,size(data1,3)) = nb_distribution;
        dataOut(~test1 & ~test2)               = data1(~test1 & ~test2);
        dataOut(~test1 & test2)                = data1(~test1 & test2);
        dataOut(test1 & ~test2)                = data2(test1 & ~test2);
        return

    end

    numberOfObs   = size(data1,1);
    numberOfPages = size(data1,3);
    dataOut       = nan(numberOfObs,1,numberOfPages);

    % Compare them where they are not nan
    bothNotNan = (~isnan(data1)) & (~isnan(data2));
    if max(abs(data1(bothNotNan) - data2(bothNotNan))) > 1e-10
        error([mfilename,':: Too big discrepancies in data vectors for variable ''' variableName ''', which was found in both dataset.'])
    end

    % Ok, then merge them
    dataOut(bothNotNan)   = data1(bothNotNan);
    DataInFirst           = (~isnan(data1)) & (isnan(data2));
    dataOut(DataInFirst)  = data1(DataInFirst);
    DataInSecond          = (isnan(data1)) & (~isnan(data2));
    dataOut(DataInSecond) = data2(DataInSecond);

end

function obj = mergeLinks(obj,DB)
% Merge updatable links of the merged objects    

    tempLinksObj               = obj.links.subLinks;
    tempLinksObj(1).operations = [tempLinksObj(1).operations, {{'merge',{}}}]; % Add a merge indicator to the operation tree.
    tempLinksDB                = DB.links.subLinks;
    mergedLinks                = nb_structdepcat(tempLinksObj,tempLinksDB);
    obj.links.subLinks         = mergedLinks;

end
