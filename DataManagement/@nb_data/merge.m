function obj = merge(obj,DB)
% Syntax:
%
% obj = merge(obj,DB)
%
% Description:
%
% Merge two nb_data objects
%
% Caution: 
% 
% - It is possible to merge datasets with the same variables as 
%   long as they represent the same data or have different 
%   spans.
% 
% - If the datsets has different number of datasets and one of the 
%   merged objects only consists of one, this object will add as
%   many datasets as needed (copies of the first dataset) so they
%   can merge.
% 
% Input:
% 
% - obj             : An object of class nb_data
% 
% - DB              : An object of class nb_data
%
% Output:
% 
% - obj : An nb_data object where the datasets from the two nb_data 
%         objects are merged
% 
% Examples:
% 
% obj = merge(obj,DB)
% obj = obj.merge(DB)
%
% See also:
% horzcat, vertcat
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_data') || ~isa(DB,'nb_data')
        error([mfilename ':: The two merged objects must both be of class nb_data.'])
    end

    % Start the merging
    %--------------------------------------------------------------
    if isempty(obj)
        obj = DB; 
    elseif isempty(DB)
        % Do nothing
    else
        
        if ~obj.isBeingUpdated 
            
            % If the object is being updated, all this stuff are
            % already been taken care of
            
            if ~isUpdateable(obj)
                startObsObj  = obj.startObs;
                variablesObj = obj.variables;
                dataObj      = obj.data;
            end

            if ~isUpdateable(DB)
                startObsDB  = DB.startObs;
                variablesDB = DB.variables;
                dataDB      = DB.data;
            end

            % If the objects are updatable we need merge things also
            % for the property links  
            if ~obj.isUpdateable() && DB.isUpdateable()

                obj.links              = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataObj;
                tempSubLink.sourceType = 'private(nb_data)';
                tempSubLink.variables  = variablesObj;
                tempSubLink.startDate  = startObsObj; % This is correct!!!
                obj.links.subLinks     = tempSubLink;
                obj.updateable         = 1;

            elseif obj.isUpdateable() && ~DB.isUpdateable()

                DB.links               = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataDB;
                tempSubLink.sourceType = 'private(nb_data)';
                tempSubLink.variables  = variablesDB;
                tempSubLink.startDate  = startObsDB; % This is correct!!!
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
        obj = obj.expand(DB.startObs,DB.endObs,'nan','warningoff');
        DB  = DB.expand(obj.startObs,obj.endObs,'nan','warningoff');
         
        % Finished with the external methods
        obj.isBeingMerged = 0;
        
        % Merge the variables
        oldVariables = obj.variables;
        if obj.sorted
            obj.variables = nb_ts.removeDuplicates(sort([obj.variables DB.variables]));
        else
            ind           = ismember(DB.variables,obj.variables);
            obj.variables = [obj.variables, DB.variables(~ind)];
        end

        % Merge the data
        tempData = nan(obj.numberOfObservations, length(obj.variables), obj.numberOfDatasets);
        for ii = 1:length(obj.variables)

            foundOld = find(strcmp(obj.variables{ii}, oldVariables),1);
            foundNew = find(strcmp(obj.variables{ii}, DB.variables),1);
            if ~isempty(foundOld) && ~isempty(foundNew)
                tempData(:,ii,:) = resolveConflictOfData(obj.data(:,foundOld,:), DB.data(:,foundNew,:), obj.variables{ii});
            elseif ~isempty(foundNew)
                tempData(:,ii,:) = DB.data(:,foundNew,:);
            else
                tempData(:,ii,:) = obj.data(:,foundOld,:);
            end

        end

        obj.data = tempData;
        
        if obj.isUpdateable() && DB.isUpdateable()
            obj = mergeLinks(obj,DB);
        end

    end
    
end

%==============================================================
% Subfunctions
%==============================================================

function dataOut = resolveConflictOfData(data1, data2, variableName)
% Subfunction which try to find out if it is possible to merge
% to data series of the same variable (which was included in 
% both datasets)

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
    BothNotNan = (~isnan(data1)) & (~isnan(data2));
    if max(abs(data1(BothNotNan) - data2(BothNotNan))) > 1e-10
        error([mfilename,':: Too big discrepancies in data vectors for variable ' variableName ', which was found in both dataset.'])
    end

    % Ok, then merge them
    dataOut(BothNotNan)   = data1(BothNotNan);
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
