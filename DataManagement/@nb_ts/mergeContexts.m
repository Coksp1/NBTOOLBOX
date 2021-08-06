function obj = mergeContexts(varargin)
% Syntax:
%
% obj = mergeContexts(varargin)
%
% Description:
%
% Merge real-time datasets that has the context dates stored in the
% dataNames property on the format 'yyyymmdd' and only represent one 
% variable.
%
% Caution: If the publishing calandar of one of the nb_ts objects is 
%          shorter than the other, the shortes of them will be expanded 
%          backwards with a quasi-real-time calandar. It will use 
%          the first publication date, and backcast the artifical
%          publication dates by the time lag of this publication date. 
%          To construct the time series of these quasi-real-time data, it 
%          will use the first vintage, and recursivly remove one 
%          observation. 
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Optional input:
% 
% - varargin : Each object must be of class nb_ts on the specific format 
%              described in the Description of this method.
% 
% Output:
% 
% - obj : The updated set of contexts stored in a nb_ts object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1 
        obj = varargin{1};
        return
    end

    if ~all(cellfun(@(x)isa(x,'nb_ts'),varargin))
        error([mfilename ':: All inputs must be nb_ts objects.'])
    end
    
    numVars = cellfun(@(x)x.numberOfVariables,varargin);
    if any(numVars > 1)
        error([mfilename ':: All nb_ts objects can only store real-time data on one variable.'])
    end
    
    vars  = cellfun(@(x)x.variables{1},varargin,'UniformOutput',false);
    uVars = unique(vars);
    if length(uVars) ~= length(vars)
        error([mfilename ':: The nb_ts objects to merge must contain unique variables'])
    end
    
    % Convert vintages to double
    contextsForEach = cell(1,nargin);
    for ii = 1:nargin
        contextsForEach{ii} = convertContexts(varargin{ii}.dataNames,['object nr. ' int2str(ii)]);
    end
    
    % Get first context date
    firstContext = min(vertcat(contextsForEach{:}));
    
    % Construct quasi-real-time data backward if context dates does not
    % match
    for ii = 1:nargin  
        if contextsForEach{ii}(1) > firstContext
            varargin{ii}        = constructQuasiRealTime(varargin{ii},contextsForEach{ii}(1),firstContext);
            contextsForEach{ii} = convertContexts(varargin{ii}.dataNames,['object nr. ' int2str(ii)]); 
        end
    end

    % Merge contexts
    contexts = unique(vertcat(contextsForEach{:}));
     
    % Secure same frequency
    freqs   = cellfun(@(x)x.frequency,varargin);
    maxFreq = max(freqs);
    loc     = find(freqs < maxFreq);
    for ii = loc
        varargin{ii} = convert(varargin{ii},maxFreq,'none','interpolateDate','end');
    end
    
    % Preallocate
    switch maxFreq
        case 4
            func = @nb_quarter;
        case 12
            func = @nb_month;
        case 52
            func = @nb_week;
        case 365
            func = @nb_day;
        otherwise
            error([mfilename ':: This method cannot handle the frequency ' nb_date.getFrequencyAsString(maxFreq)])
    end
            
    startDates(1,nargin) = func();
    for ii = 1:nargin
        startDates(ii) = varargin{ii}.startDate;
    end
    start    = min(startDates);
    endDates = startDates;
    for ii = 1:nargin
        endDates(ii) = varargin{ii}.endDate;
    end
    finish = max(endDates);
    T      = (finish - start) + 1;
    
    % Get real end dates for each variable
    realEndDates    = cell(1,nargin);
    minRealEndDates = finish;
    for ii = 1:nargin
        realEndDates{ii} = getRealEndDatePages(varargin{ii},'nb_date');
        if realEndDates{ii}(1) < minRealEndDates
            minRealEndDates = realEndDates{ii}(1);
        end
    end
    
    % The first contexts is special
    for vv = 1:nargin
        contextsForEach{vv} = [contextsForEach{vv};inf];
    end
    
    % Get the start vintage of each series, starting from the first real
    % vintage of any of the series, i.e. so that we don't start with a 
    % context only consisting of quasi-real-time vintages
    kk = ones(1,nargin);
    for vv = 1:nargin
        while contextsForEach{vv}(kk(vv)) < firstContext
            kk(vv) = kk(vv) + 1;
        end
    end
    
    % Construct rest of the contexts
    ind              = find(firstContext == contexts,1);
    filteredContexts = contexts(ind:end);
    nContexts        = length(filteredContexts);
    d                = nan(T,nargin,nContexts);
    for ii = 1:nContexts
        
        for vv = 1:nargin
            
            if contextsForEach{vv}(kk(vv)) == filteredContexts(ii) 
                nObs                   = realEndDates{vv}(kk(vv)) - start + 1;
                nObsOne                = realEndDates{vv}(kk(vv)) - startDates(vv) + 1;
                startOne               = nObs - nObsOne + 1;
                d(startOne:nObs,vv,ii) = varargin{vv}.data(1:nObsOne,:,kk(vv));
                if ii < nContexts
                    kk(vv) = kk(vv) + 1;
                end
            else
                if kk(vv) == 1
                    ind = 1;
                else
                    ind = kk(vv) - 1;
                end
                nObs                   = realEndDates{vv}(ind) - start + 1;
                nObsOne                = realEndDates{vv}(ind) - startDates(vv) + 1;
                startOne               = nObs - nObsOne + 1;
                d(startOne:nObs,vv,ii) = varargin{vv}.data(1:nObsOne,:,ind);
            end
            
        end
        
    end
    
    % Construct new object
    obj               = varargin{1};
    obj.isBeingMerged = false;
    obj.data          = d;
    obj.startDate     = start;
    obj.endDate       = finish;
    obj.variables     = vars;
    obj.dataNames     = cellstr(num2str(filteredContexts))';
    if obj.sorted
        [obj.variables,loc] = sort(obj.variables);
        obj.data            = obj.data(:,loc,:);
    end
    
    if obj.isUpdateable()
        % This method break the link to the data for know...
        obj.links      = struct([]);
        obj.updateable = 0;
    end
    
end

%==========================================================================
function contexts = convertContexts(contexts,input)

    contexts = char(contexts');
    if size(contexts,2) ~= 8
        error([mfilename ':: All the names of the datasets of the input ' input ' must have the format ''yyyymmdd''.'])
    end
    contexts = str2num(contexts); %#ok<ST2NM>
    if isempty(contexts)
        error([mfilename ':: All the names of the datasets of the input ' input ' must have the format ''yyyymmdd''.'])
    end
    
end

%==========================================================================
function [y,m,d] = getContextInfo(context)

    y = str2num(context(:,1:4)); %#ok<ST2NM>
    m = str2num(context(:,5:6)); %#ok<ST2NM>
    d = str2num(context(:,7:8)); %#ok<ST2NM>
    
end

%==========================================================================
function obj = constructQuasiRealTime(obj,contextThis,firstContext)

    [y1,m1,d1] = getContextInfo(num2str(contextThis));
    [y2,m2,d2] = getContextInfo(num2str(firstContext));

    % Get number of added contexts
    if obj.frequency == 4
        
        dateM1 = nb_month(m1,y1);
        dateM2 = nb_month(m2,y2);
        func   = @getQuarter;
        date1  = func(dateM1);
        date2  = func(dateM2);
        
    elseif obj.frequency == 12
        
        date1 = nb_month(m1,y1);
        date2 = nb_month(m2,y2);
        func  = @getMonth;
        
    else
        
        dateD1 = nb_day(d1,m1,y1);
        dateD2 = nb_day(d2,m2,y2);
        func   = @getWeek;
        date1  = func(dateD1);
        date2  = func(dateD2);
        
    end
    nNewContexts = date1 - max(date2,obj.startDate + obj.frequency) + 1;
    if nNewContexts == 0
        return
    end
    
    % Get new publication days
    newContexts = getNewContexts(obj,func,nNewContexts);
    newContexts = sort(vertcat(newContexts{:}));
    
    % Create the quasi-real-time series
    data     = obj.data(:,:,1:1);
    rEndDate = getRealEndDate(window(obj,'','','',1),'nb_date');
    loc      = rEndDate - obj.startDate + 1;
    newData  = repmat(data,[1,1,nNewContexts]);
    for ii = nNewContexts:-1:1
        % Apply same ragged edge backward in time
        newData(loc:end,:,ii) = nan;
        loc                   = loc - 1;
    end
    obj.data      = nb_depcat(newData,obj.data);
    obj.dataNames = [newContexts', obj.dataNames];

end

%==========================================================================
function [newContexts,newREndDates] = getNewContexts(obj,func,nNewContexts)

    pDate    = nb_date.vintage2Date(obj.dataNames{1},365);
    weekD    = weekday(pDate);
    perDate  = func(pDate);
    rEndDate = getRealEndDate(window(obj,'','','',1),'nb_date');
    if obj.frequency == 4
        quarterLag = perDate - rEndDate;
        month      = getMonth(pDate);
        monthLag   = month - perDate.getMonth();
        weekLag    = getWeek(pDate) - getWeek(month); 
    elseif obj.frequency == 12
        monthLag   = perDate - rEndDate;
        weekLag    = getWeek(pDate) - getWeek(perDate); 
    else
        weekLag = getWeek(pDate) - perDate;
    end
    newREndDates = rEndDate.toDates(-nNewContexts:-1,'nb_date');
    newContexts  = newREndDates;
    newREndDates = {newREndDates};
    if  obj.frequency < 12
        newContexts = newContexts + quarterLag;
        newContexts = getMonth(newContexts);
    end
    if  obj.frequency < 52
        newContexts = newContexts + monthLag;
        newContexts = getWeek(newContexts);
    end
    newContexts = newContexts + weekLag;
    newContexts = setDayOfWeek(newContexts,weekD);
    newContexts = getDay(newContexts,2);
    newContexts = toString(newContexts,'xls');
    newContexts = {nb_xlsDates2FAMEVintage(newContexts)};
    
end

%==========================================================================
% function [obj,contextsNew] = syncVintages(obj,contexts,contextsAnother)
% 
%     [y1,m1,d1] = getContextInfo(num2str(contexts));
%     [y2,m2,d2] = getContextInfo(num2str(contextsAnother));
%     for ii = 1:size(y1,1)   
%         ind = y1(ii) == y2 & m1(ii) == m2;
%         if any(ind)
%             d1(ii) = d2(ind);
%         end
%     end
%     contextsNew   = strcat(cellstr(num2str(y1)),strrep(cellstr(num2str(m1)),' ','0'),strrep(cellstr(num2str(d1)),' ','0'));
%     obj.dataNames = contextsNew';
%     contextsNew   = str2num(char(contextsNew));
%     
% end
