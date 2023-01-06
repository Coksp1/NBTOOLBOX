function obj = merge(obj,DB,interpolateDate,method,rename,append,type)
% Syntax:
%
% obj = merge(obj,DB)
% obj = merge(obj,DB,interpolateDate,method,rename,append,type)
%
% Description:
%
% Merge two nb_ts objects. Same as obj = [obj,DB]
%
% Caution: 
% 
% - It is possible to merge datasets with the same variables as 
%   long as they represent the same data or have different 
%   timespans.
% 
% - If the datsets has different number of datasets and one of the 
%   merged objects only consists of one, this object will add as
%   many datasets as needed (copies of the first dataset) so they
%   can be merged.
% 
% - If any of the datasets are of type real-time, they cannot
%   contain the same variables.
%
% - If one dataset is of type real-time, then the other dataset
%   will need to only have one page. The other dataset will
%   get the same recursive structure as the real-time dataset.
%
% - If two real-time datasets are merge the last vintage of the
%   two dataset cannot differ, when it comes to the endDate, by
%   more than one period. If thy differ by one period it is assumed
%   that this is the case for all vintages backard in time as well,
%   i.e. the regged edge of the last period is perserved for all
%   vintages.
%
% - If two real-time datasets are merge and one of them have more
%   vintages backward in time, the one with the fewest vintages 
%   will be expanded with the same number of vintages as the other
%   dataset. The first avilable vintage then be used to construct
%   these vintages.
%
% - If two real-time datasets are merged you should first use the
%   method cleanRealTime on both inputs!
%
% Input:
% 
% - obj             : An object of class nb_ts
% 
% - DB              : An object of class nb_ts
% 
% - interpolateDate : 
%
%         How to transform the database with the lowest 
%         frequency.
%
%         - 'start' : The interpolated data are taken as given at 
%                     the start of the periods. I.e. use 01.01.2012 
%                     and 01.01.2013 when interpolating data with 
%                     yearly frequency. (Default)                             
% 
%         - 'end'   : The interpolated data are taken as given at 
%                     the end of the periods. I.e. use 31.12.2012 
%                     and 31.12.2013 when interpolating data with 
%                     yearly frequency.
% 
% - method          : The method to use when converting:
%
%                     - 'linear'   : Linear interpolation
%                     - 'cubic'    : Shape-preserving piecewise 
%                                    cubic interpolation 
%                     - 'spline'   : Piecewise cubic spline 
%                                    interpolation  
%                     - 'none'     : No interpolation. All data in  
%                                    between is given by nans 
%                                    (missing values)(Default)
%                     - 'fill'     : No interpolation. All periods  
%                                    of the higher frequency get 
%                                    the same value as that of the 
%                                    lower frequency.
% 
% - rename          : > 'on'  : Renames the prefixes (default)
%                     > 'off' : Do not rename the prefixes
%
%                     For more see the 'rename' option of the 
%                     convert method.
%
% - append          : > 0 : If data is conflicting an error will occure.
%                           default.
%                     > 1 : If data is conflicting data of the first 
%                           database will be used.
%
% - type            : The type of series to merge. Only when append is 
%                     equal to 1.
%
%                     > 'levelGrowth' : Merge level data with growth
%                                       rates. Must be one period growth.
%                                       The merged series will be in level.
%
%                     > 'growthLevel' : Merge growth rates with level data. 
%                                       Must be one period growth. The
%                                       merged series will be in growth
%                                       rates.
%
%                     > 'levelLevel'  : Merge level series, where the
%                                       merging is done in growth rates,
%                                       but the end result is still in
%                                       levels. 
%
%                     > ''            : Standard merging.
%
%                     If two real-time datasets are merge:
%                     
%                     > 'pages' : In this case the merging of the
%                                 real-time databases is taken page by page
%                                 starting from the last page. If some of
%                                 the datasets have more pages than the 
%                                 other a error will be given.
%
%                     > ''      : Default merging of real-time datasets.
%                                 See the description part.
%
% Output:
% 
% - obj : An nb_ts object where the datasets from the two nb_ts 
%         objects are merged
% 
% Examples:
% 
% obj = merge(obj,DB)
% obj = obj.merge(DB)
%
% See also: 
% nb_ts.append, nb_dataSource.merge2Series
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        type = '';
        if nargin < 6
            append = 0;
            if nargin < 5
                rename = 'on';
                if nargin < 4
                    method = 'none';
                    if nargin < 3
                        interpolateDate = 'start';
                    end
                end
            end
        end
    end

    if ~isa(obj,'nb_ts') || ~isa(DB,'nb_ts')
        error([mfilename ':: The two merged objects must both be of class nb_ts.'])
    end
    
    if isRealTime(obj) || isRealTime(DB)
        obj = mergeRealTime(obj,DB,type);
        return
    end
    
    if isempty(interpolateDate)
        interpolateDate = 'start';
    end
    
    if isempty(method)
        method = 'none';
    end
    
    if isempty(rename)
        rename = 'on';
    end
    
    if isempty(append)
        append = 0;
    end
    
    % Merge local variables
    %-------------------------------
    try
        obj.localVariables = nb_structcat(obj.localVariables,DB.localVariables);
    catch Err
        error([mfilename ':: Could not merge the local variables from the two nb_ts objects. ' Err.message])
    end

    % Start the merging
    %--------------------------------------------------------------
    if isempty(obj)
        obj = DB; 
    elseif isempty(DB)
        % Do nothing
    else
        
        if ~obj.isBeingUpdated 
            
            if ~isUpdateable(obj)
                startDateObj = obj.startDate;
                variablesObj = obj.variables;
                dataObj      = obj.data;
            end

            if ~isUpdateable(DB)
                startDateDB = DB.startDate;
                variablesDB = DB.variables;
                dataDB      = DB.data;
            end

            % If the objects are updatable we need merge things also
            % for the property links  
            if ~obj.isUpdateable() && DB.isUpdateable()

                obj.links              = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataObj;
                tempSubLink.sourceType = 'private(nb_ts)';
                tempSubLink.variables  = variablesObj;
                tempSubLink.startDate  = startDateObj;
                obj.links.subLinks     = tempSubLink;
                obj.updateable         = 1;

            elseif obj.isUpdateable() && ~DB.isUpdateable()

                DB.links               = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataDB;
                tempSubLink.sourceType = 'private(nb_ts)';
                tempSubLink.variables  = variablesDB;
                tempSubLink.startDate  = startDateDB;
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

        % Transform the dataset with the lowest frequency to the
        % highest frequency, if the frequencies are not the same
        if obj.frequency ~= DB.frequency

            if isa(obj.data,'nb_distribution') || isa(DB.data,'nb_distribution')
                error([mfilename ':: Cannot convert the frequency of a nb_ts object representing nb_distribution objects.'])
            end
            
            if strcmp(rename,'on')

                if obj.startDate.frequency < DB.startDate.frequency
                    obj = convert(obj,DB.frequency,method,'rename','interpolateDate',interpolateDate); % Data in between are given nans
                else
                    DB  = convert(DB,obj.frequency,method,'rename','interpolateDate',interpolateDate); % Data in between are given nans
                end

            else

                if obj.startDate.frequency < DB.startDate.frequency
                    obj = convert(obj,DB.frequency,method,'interpolateDate',interpolateDate); % Data in between are given nans
                else
                    DB  = convert(DB,obj.frequency,method,'interpolateDate',interpolateDate); % Data in between are given nans
                end

            end

        end

        % Merge the dates and expand the data of both databases
        obj = obj.expand(DB.startDate,DB.endDate,'nan','warningoff');
        DB  = DB.expand(obj.startDate,obj.endDate,'nan','warningoff');
           
        % Finished with the external methods
        obj.isBeingMerged = 0;
        
        % Merge the variables
        oldVariables = obj.variables;
        if obj.sorted
            obj.variables = nb_ts.removeDuplicates(sort([obj.variables DB.variables]));
        else
            ind           = ismember(DB.variables,obj.variables);
            obj.variables = [obj.variables DB.variables(~ind)];
        end

        % Merge the data
        if isa(obj.data,'nb_distribution')
            tempData(obj.numberOfObservations, length(obj.variables), obj.numberOfDatasets) = nb_distribution;
        else
            tempData = nan(obj.numberOfObservations, length(obj.variables), obj.numberOfDatasets);
        end
        for ii = 1:length(obj.variables)

            foundOld = find(strcmp(obj.variables{ii}, oldVariables),1);
            foundNew = find(strcmp(obj.variables{ii}, DB.variables),1);
            if ~isempty(foundOld) && ~isempty(foundNew)
                tempData(:,ii,:) = resolveConflictOfData(obj.data(:,foundOld,:), DB.data(:,foundNew,:), obj.variables{ii},append,type);
            elseif ~isempty(foundNew)
                tempData(:,ii,:) = DB.data(:,foundNew,:);
            else
                tempData(:,ii,:) = obj.data(:,foundOld,:);
            end

        end

        obj.data = tempData;
        
        if obj.isUpdateable() && DB.isUpdateable()
            obj = mergeLinks(obj,DB,append,interpolateDate,method,rename,type);
        end

    end
    
end

%==============================================================
% Subfunctions
%==============================================================

function dataOut = resolveConflictOfData(data1,data2,variableName,append,type)
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
    if any(BothNotNan)
        if max(abs(data1(BothNotNan) - data2(BothNotNan))) > 1e-10 && ~append
            error([mfilename,':: Too big discrepancies in data vectors for variable ' variableName ', which was found in both dataset.'])
        end
    end

    % Transform variables before merging
    switch lower(type)
        case 'levelgrowth'
            start = data1;
            data1 = growth(data1);
        case 'levelegrowth'
            start = data1;
            data1 = egrowth(data1);   
        case 'levelpcn'
            start = data1;
            data1 = pcn(data1);  
        case 'levelepcn'
            start = data1;
            data1 = epcn(data1);      
        case 'growthlevel'
            data2 = growth(data2);
        case 'levellevel'
            start = data1;
            data1 = growth(data1);
            data2 = growth(data2);
    end

    % Ok, then merge them
    dataOut(BothNotNan)   = data1(BothNotNan);
    DataInFirst           = (~isnan(data1)) & (isnan(data2));
    dataOut(DataInFirst)  = data1(DataInFirst);
    DataInSecond          = (isnan(data1)) & (~isnan(data2));
    dataOut(DataInSecond) = data2(DataInSecond);

    % Transform back 
    switch lower(type)
        case {'levelgrowth','levellevel'}
            dataOut = igrowthnan(dataOut,start);
        case 'levelegrowth'
            dataOut = iegrowthnan(dataOut,start);   
        case 'levelpcn'
            dataOut = ipcnnan(dataOut,start); 
        case 'levelepcn'
            dataOut = iepcnnan(dataOut,start);    
    end

end

%==================================================================
function obj = mergeLinks(obj,DB,append,interpolateDate,method,rename,type)
% Merge updatable links of the merged objects    

    if append 
        operator = {'mergeappend',{interpolateDate,method,rename,1,type}};
    else
        operator = {'merge',{interpolateDate,method,rename}};
    end
    tempLinksObj               = obj.links.subLinks;
    tempLinksObj(1).operations = [tempLinksObj(1).operations, {operator}]; % Add a merge indicator to the operation tree.
    tempLinksDB                = DB.links.subLinks;
    mergedLinks                = nb_structdepcat(tempLinksObj,tempLinksDB);
    obj.links.subLinks         = mergedLinks;

end

%==================================================================
function obj = mergeRealTime(obj,DB,type)

    ret1 = isRealTime(obj);
    ret2 = isRealTime(DB);
    if ret1 && ret2
        if strcmpi(type,'pages')
            obj = mergeRealTimePages(obj,DB);
        else
            obj = mergeRealTimeWithRealTime(obj,DB);
        end
    elseif ret1
        if strcmpi(type,'pages')
            obj = mergeRealTimeWithNormalPages(obj,DB);
        else
            obj = mergeRealTimeWithNormal(obj,DB);
        end
    else
        if strcmpi(type,'pages')
            obj = mergeRealTimeWithNormalPages(DB,obj);
        else
            obj = mergeRealTimeWithNormal(DB,obj);
        end
    end
    
end

%==================================================================
function obj = mergeRealTimePages(obj,DB)

    if obj.numberOfDatasets ~= DB.numberOfDatasets
        error([mfilename ':: If type is set to ''pages'' the number of datasets (pages) must be equal. (' int2str(obj.numberOfDatasets) ' vs ' int2str(DB.numberOfDatasets) ')'])
    end
    test = ismember(DB.variables,obj.variables);
    if any(test)
        error([mfilename ':: The two datasets cannot have the same variables when merging two real-time datasets; ' toString(DB.variables(test))])
    end

    if obj.startDate.frequency ~= DB.startDate.frequency
        error('nb_ts:merge:realTime:diffFreq',...
              [mfilename ':: Cannot merge real-time datasets with different frequencies (' nb_date.getFrequencyAsString(obj.startDate.frequency) ' vs ' nb_date.getFrequencyAsString(DB.startDate.frequency) ').'])
    end
    
    % Secure same time span
    periods = obj.startDate - DB.startDate;
    if periods > 0
        obj.data      = [nan(periods,obj.numberOfVariables,obj.numberOfDatasets);obj.data];
        obj.startDate = DB.startDate;
    elseif periods < 0
        DB.data      = [nan(abs(periods),DB.numberOfVariables,DB.numberOfDatasets);DB.data];
        DB.startDate = obj.startDate;
    end
    
    periods = obj.endDate - DB.endDate;
    if periods < 0
        obj.data    = [obj.data;nan(abs(periods),obj.numberOfVariables,obj.numberOfDatasets)];
        obj.endDate = DB.endDate;
    elseif periods > 0
        DB.data    = [DB.data;nan(periods,DB.numberOfVariables,DB.numberOfDatasets)];
        DB.endDate = obj.endDate;
    end
    
    % Then we merge
    vars   = [obj.variables,DB.variables];
    dataM  = [obj.data,DB.data];
    if obj.sorted
        [vars,indV] = sort(vars);
        dataM       = dataM(:,indV,:);
    end

    % Update properties
    obj.variables = vars;
    obj.data      = dataM;
    
    % Merge the links as well
    obj = mergeLinks(obj,DB,false,'start','none','on','pages');
    
    
end

%==================================================================
function obj = mergeRealTimeWithRealTime(obj,DB)

    test = ismember(DB.variables,obj.variables);
    if any(test)
        error([mfilename ':: The two datasets cannot have the same variables when merging two real-time datasets; ' toString(DB.variables(test))])
    end

    if obj.startDate.frequency ~= DB.startDate.frequency
        error('nb_ts:merge:realTime:diffFreq',...
              [mfilename ':: Cannot merge real-time datasets with different frequencies (' nb_date.getFrequencyAsString(obj.startDate.frequency) ' vs ' nb_date.getFrequencyAsString(DB.startDate.frequency) ').'])
    end
    
    % Secure same time span
    periods = obj.startDate - DB.startDate;
    if periods > 0
        obj.data      = [nan(periods,obj.numberOfVariables,obj.numberOfDatasets);obj.data];
        obj.startDate = DB.startDate;
    elseif periods < 0
        DB.data      = [nan(abs(periods),DB.numberOfVariables,DB.numberOfDatasets);DB.data];
        DB.startDate = obj.startDate;
    end
    
    periods = obj.endDate - DB.endDate;
    if periods < 0
        obj.data    = [obj.data;nan(abs(periods),obj.numberOfVariables,obj.numberOfDatasets)];
        obj.endDate = DB.endDate;
    elseif periods > 0
        DB.data    = [DB.data;nan(periods,DB.numberOfVariables,DB.numberOfDatasets)];
        DB.endDate = obj.endDate;
    end
    
    % Find the end points for each vintage
    ind1 = findEndPoints(obj.data);
    ind2 = findEndPoints(DB.data);
    if any(diff(ind1) ~= 1)
        error([mfilename ':: One of the vintages does not provided a single new observation (and only that) '...
                        'for the first nb_ts object. Please see the cleanRealTime method.'])
    end
    if any(diff(ind2) ~= 1)
        error([mfilename ':: One of the vintages does not provided a single new observation (and only that) '...
                        'for the second nb_ts object. Please see the cleanRealTime method.'])
    end
    
    % Secure same vintage structure
    if ind1(end) ~= ind2(end)
        % If the last vintage of one of the databases provide a 
        % longer sample we keep this ragged edge backward in time 
        % as well
        if ind1(end) == ind2(end) + 1
            ind2 = ind2 + 1;
        elseif ind1(end) + 1 == ind2(end)
            ind1 = ind1 + 1;
        else
           error([mfilename ':: The last vintages of the two databases cannot differ, in terms of how many observations they provide, by more than 1.']) 
        end
    end
    obj = secureSameEndPoints(obj,ind1,ind2);
    DB  = secureSameEndPoints(DB,ind2,ind1);
    
    % Then we merge
    vars   = [obj.variables,DB.variables];
    dataM  = [obj.data,DB.data];
    if obj.sorted
        [vars,indV] = sort(vars);
        dataM       = dataM(:,indV,:);
    end

    % Update properties
    obj.variables = vars;
    obj.data      = dataM;
    obj.dataNames = toString(obj.startDate + (unique([ind1;ind2])' - 1));

    % Merge the links as well
    obj = mergeLinks(obj,DB,false,'start','none','on','');
    
    
end

%==================================================================
function obj = mergeRealTimeWithNormal(obj,DB)

    if isempty(DB)
        return
    end

    if DB.numberOfDatasets > 1
        error([mfilename ':: Cannot merge a real-time dataset with another multi-paged dataset, which is not itself a real-time dataset!'])
    end
    
    test = ismember(DB.variables,obj.variables);
    if any(test)
        error([mfilename ':: The two datasets cannot have the same variables when one of them are real-time dataset; ' toString(DB.variables(test))])
    end
    if obj.startDate < DB.startDate
        error([mfilename ':: The start date of the non-real-time dataset cannot be after the start date of the real-time dataset.'])
    elseif obj.endDate > DB.endDate
        error([mfilename ':: The end date of the non-real-time dataset cannot be before the end date of the real-time dataset.'])
    end
    
    % Merge the datasets
    indS   = obj.startDate - DB.startDate + 1;
    indE   = obj.endDate - DB.startDate + 1;
    dataDB = DB.data(indS:indE,:,ones(1,obj.numberOfDatasets));
    dataDB = forceLadder(obj,dataDB);
    vars   = [obj.variables,DB.variables];
    dataM  = [obj.data,dataDB];
    if obj.sorted
        [vars,indV] = sort(vars);
        dataM       = dataM(:,indV,:);
    end

    % Update properties
    obj.variables = vars;
    obj.data      = dataM;
    
    % If the objects are updatable we need merge things also
    % for the property links  
    if ~DB.isUpdateable()
        
        DB.links               = struct('subLinks',struct());
        tempSubLink            = nb_createDefaultLink;
        tempSubLink.source     = dataDB;
        tempSubLink.sourceType = 'private(nb_ts)';
        tempSubLink.variables  = DB.variables;
        tempSubLink.startDate  = DB.startDate;
        DB.links.subLinks      = tempSubLink;
        DB.updateable          = 1;

    end
    obj = mergeLinks(obj,DB,false,'start','none','on','pages');
    
end

%==================================================================
function obj = mergeRealTimeWithNormalPages(obj,DB)

    if isempty(DB)
        return
    end

    if DB.numberOfDatasets ~= obj.numberOfDatasets
        error([mfilename ':: Cannot merge a real-time dataset with another multi-paged dataset, where the number of datasets are conflicting!'])
    end
    
    test = ismember(DB.variables,obj.variables);
    if any(test)
        error([mfilename ':: The two datasets cannot have the same variables when one of them are real-time dataset; ' toString(DB.variables(test))])
    end
    
    % Secure the same time span
    periods = obj.startDate - DB.startDate;
    if periods > 0
        obj.data      = [nan(periods,obj.numberOfVariables,obj.numberOfDatasets);obj.data];
        obj.startDate = DB.startDate;
    elseif periods < 0
        DB.data      = [nan(abs(periods),DB.numberOfVariables,DB.numberOfDatasets);DB.data];
        DB.startDate = obj.startDate;
    end
    
    periods = obj.endDate - DB.endDate;
    if periods < 0
        obj.data    = [obj.data;nan(abs(periods),obj.numberOfVariables,obj.numberOfDatasets)];
        obj.endDate = DB.endDate;
    elseif periods > 0
        DB.data    = [DB.data;nan(periods,DB.numberOfVariables,DB.numberOfDatasets)];
        DB.endDate = obj.endDate;
    end
    
    % Merge the datasets
    vars  = [obj.variables,DB.variables];
    dataM = [obj.data,DB.data];
    if obj.sorted
        [vars,indV] = sort(vars);
        dataM       = dataM(:,indV,:);
    end

    % Update properties
    obj.variables = vars;
    obj.data      = dataM;

    % If the objects are updatable we need merge things also
    % for the property links  
    if ~DB.isUpdateable()
        
        DB.links               = struct('subLinks',struct());
        tempSubLink            = nb_createDefaultLink;
        tempSubLink.source     = DB.data;
        tempSubLink.sourceType = 'private(nb_ts)';
        tempSubLink.variables  = DB.variables;
        tempSubLink.startDate  = DB.startDate;
        DB.links.subLinks      = tempSubLink;
        DB.updateable          = 1;

    end
    obj = mergeLinks(obj,DB,false,'start','none','on','');
    
end

%==================================================================
function dataDB = forceLadder(obj,dataDB)

    d = obj.data;
    for ii = 1:obj.numberOfDatasets
        ind                    = find(any(~isnan(d(:,:,ii)),2),1,'last');
        dataDB(ind+1:end,:,ii) = nan;
    end
    
end

%==================================================================
function ind = findEndPoints(d)

    ind = nan(size(d,3),1);
    for ii = 1:size(d,3)
        ind(ii) = find(any(~isnan(d(:,:,ii)),2),1,'last');
    end
    
end

%==================================================================
function obj = secureSameEndPoints(obj,ind1,ind2)

    indBefore = ind2(ind2 < ind1(1));
    if isempty(indBefore)
        return
    end
    corr = ind1(1) - (getRealEndDate(window(obj,'','','',1)) - obj.startDate) - 1;
    new = nan(obj.numberOfObservations,obj.numberOfVariables,length(indBefore));
    for ii = 1:length(indBefore)
        new(1:indBefore(ii)-corr,:,ii) = obj.data(1:indBefore(ii)-corr,:,1);
    end
    obj.data             = nb_depcat(new,obj.data);  
    
end
