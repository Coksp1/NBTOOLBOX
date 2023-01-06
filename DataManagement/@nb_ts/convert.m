function obj = convert(obj,freq,method,varargin)
% Syntax:
%
% obj = convert(obj,freq,method,varargin)
%
% Description:
% 
% Convert the frequency of the data of the nb_ts object
% 
% Input:
% 
% - obj    : An object of class nb_ts
% 
% - freq   : The new freqency of the data. As an integer:
% 
%            > 1   : yearly
%            > 2   : semi annually
%            > 4   : quarterly
%            > 12  : monthly
%            > 52  : weekly
%            > 365 : daily
% 
% - method : The method to use. Either:
% 
%            From a high frequency to a low:
% 
%            > 'average'     : Takes averages over the subperiods
%            > 'diffAverage' : Uses a weighted average, so that the
%                              diff operators can be converted
%                              correctly. E.g. when converting from monthly
%                              to quarterly, and the level of the variable
%                              of interest is aggregated to quarterly data
%                              using averages, but you want to convert
%                              monthly data on diff to quarterly. The 
%                              formula used is:
%                              diff_Y(q) = 1/3*diff_Y(m) + 2/3*diff_Y(m-1)  
%                                        + diff_Y(m-2) + 2/3*diff_Y(m-3) 
%                                        + 1/3*diff_Y(m-4)
%            > 'diffSum'     : Same as 'diffAverage', but now the
%                              aggregation in levels are done using a sum
%                              instead.
%            > 'discrete'    : Takes last observation in each 
%                              subperiod (Default)
%            > 'first'       : Takes first observation in each 
%                              subperiod 
%            > 'max'         : Takes maximal value over the subperiods
%            > 'min'         : Takes minimum value over the subperiods
%            > 'sum'         : Takes sums over the subperiods        
% 
%            From a low frequency to a high:
% 
%            > 'linear'   : Linear interpolation
%            > 'cubic'    : Shape-preserving piecewise cubic 
%                           interpolation 
%            > 'spline'   : Piecewise cubic spline interpolation  
%            > 'none'     : No interpolation. All data in between 
%                           is given by nans (missing values) 
%                           (Default)
%            > 'fill'     : No interpolation. All periods of the 
%                           higher frequency get the same value as
%                           that of the lower frequency.
%            > 'daverage' : Uses the Denton 1971 method using that
%                           the average of the intra low frequency
%                           periods should preserve the average.
%            > 'dsum'     : Uses the Denton 1971 method using that
%                           the sum of the intra low frequency
%                           periods should preserve the sum.
% 
%            Caution: This input must be given if you provide some 
%                     of the optional inputs.
%          
%            Caution: All these option will by default use the 
%                     first period of the subperiods as base for 
%                     the conversion. Provide the optional input
%                     'interpolateDate' if you want to set the base
%                     to the end periods instead ('end').        
% 
% Optional input:
% 
% - 'includeLast' : Give this string as input if you want to 
%                   include the last period, even if it is not 
%                   finished. Only when converting to lower 
%                   frequencies
% 
%                   E.g: obj = obj.convert(1,'average',...
%                   'includeLast');
% 
% - 'rename'      : Changes the postfixes of the variables names.
% 
%                   E.g. If you covert from the frequency 12 to 4 
%                        the prefixes of the variable names changes 
%                        from 'MUA' to 'QUA', if the prefix exist.
% 
%                   E.g: obj = obj.convert('yearly','average',...
%                                          'rename');
% 
% 
% Optional input (...,'inputName',inputValue,...):
% 
% - 'fill'            : Either 'nan' (default) or 'zeros'. This set how 
%                       to fill the values that are not set when method  
%                       is set to 'none'.
%
% - 'interpolateDate' : The input after this input must either be
%                       'start', 'end' or a scalar integer.
% 
%                       Date of interpolation. Where 'start' means 
%                       to interpolate the start date of the 
%                       periods of the old frequency, while 'end' 
%                       uses the end date of the periods. If a scalar
%                       integer is added it is taken as 'end' minus the
%                       given number of periods.
% 
%                       Default is 'start'.
% 
%                       Caution : Only when converting to higher
%                                 frequency.
%
%                       Caution : For weekly data, the 'dayOfWeek' options
%                                 is added. See nb_ts.setDayOfWeek for more
%                                 on this.
% 
%                       E.g: obj = obj.convert(365,'linear',...
%                       'interpolateDate','end');
% 
% Output:
% 
% - obj : An nb_ts object converted to wanted frequency.
% 
% Examples:
% 
% obj = obj.convert(4,'average'); 
% obj = obj.convert(365,'linear','interpolateDate','end');
% obj = obj.convert(1,'average','includeLast');  
% obj = obj.convert(1,'average','rename');
%
% See also:
% nb_ts.convertEach
%
% Written by Kenneth S. Paulsen                                   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        method = '';
    end

    if isempty(method)
        if freq > obj.frequency
            method = 'none';
        else
            method = 'discrete';
        end 
    end
    
    interpolateDate = 'start';
    rename          = 'off';
    includeLast     = 'off';
    fill            = 'nan';
    for ii = 1:size(varargin,2)

        if ischar(varargin{ii})

            switch lower(varargin{ii})
                case 'rename'
                    rename = 'on';
                case 'includelast'
                    includeLast = 'on';
                case 'interpolatedate'
                    interpolateDate = varargin{ii + 1};
                case 'fill'
                    fill = varargin{ii + 1};
            end
            
        elseif nb_isScalarInteger(varargin{ii})
            
            switch lower(varargin{ii})
                case 'interpolatedate'
                    interpolateDate = varargin{ii + 1};
            end
            
        else
            error([mfilename ':: All optional inputs to this function must be strings.'])
        end

    end
    if nb_isScalarInteger(interpolateDate)
        interpolateLag  = interpolateDate;
        interpolateDate = 'end';
    else
        interpolateLag  = 0;
    end

    oldFreq = obj.frequency;
    if obj.frequency == freq

        warning('nb_ts:convert:ConvertToSameFrequency',[mfilename ':: The frequency of the data is already; ' nb_date.getFrequencyAsString(freq)]); 

    %--------------------------------------------------------------   
    % Convert to higer frequency
    %--------------------------------------------------------------
    elseif obj.frequency < freq

        if strcmpi(method,'daverage') || strcmpi(method,'dsum')
            refPeriod1 = 1;
            refPeriod2 = 0;
        else
            if strcmpi(interpolateDate,'end')
                refPeriod1 = 0;
                refPeriod2 = 0;
            else
                refPeriod1 = 1;
                refPeriod2 = 1;
            end
        end
        
        if strcmpi(method,'none') || strcmpi(method,'daverage') || strcmpi(method,'dsum')

            switch freq 

                case 365
                    startDateNew = obj.startDate.getDay(refPeriod1);
                    endDateNew   = obj.endDate.getDay(refPeriod2);
                case 52
                    startDateNew = obj.startDate.getWeek(refPeriod1);
                    endDateNew   = obj.endDate.getWeek(refPeriod2);
                case 12
                    startDateNew = obj.startDate.getMonth(refPeriod1);
                    endDateNew   = obj.endDate.getMonth(refPeriod2);
                case 4
                    startDateNew = obj.startDate.getQuarter(refPeriod1);
                    endDateNew   = obj.endDate.getQuarter(refPeriod2);
                case 2
                    startDateNew = obj.startDate.getHalfYear(refPeriod1);
                    endDateNew   = obj.endDate.getHalfYear(refPeriod2);
                otherwise
                    error([mfilename ':: Unsuported frequency ' int2str(freq)])
            end

            if strcmpi(method,'none')
                % Match the data and the dates
                newPeriods = endDateNew - startDateNew; 
                periods    = obj.endDate - obj.startDate;
                if freq == 52
                    obsDatesObj = obj.startDate + (0:periods);
                    obsDatesObj = obsDatesObj.getWeek(refPeriod1);
                    newDatesObj = startDateNew + (0:newPeriods);
                    [~,loc]     = ismember(obsDatesObj,newDatesObj);
                else
                    start = obj.startDate;
                    if obj.frequency == 52
                        % Weekly converted to daily
                        if strcmpi(interpolateDate,'end')
                            start.dayOfWeek = 1; % Sunday
                        elseif strcmpi(interpolateDate,'dayOfWeek')
                            % Correct the start and end dates at the daily
                            % frequency
                            wDay = start.dayOfWeek;
                            if wDay == 1
                                wDay = 7;
                            else
                                wDay = wDay - 1;
                            end
                            startDateNew = startDateNew + (wDay - 1);
                            endDateNew   = endDateNew + (wDay - 1);
                        else
                            start.dayOfWeek = 2; % Monday
                        end
                    end
                    obsDates = start.toDates(0:periods,'xls',obj.frequency,refPeriod1);
                    newDates = startDateNew.toDates(0:newPeriods,'xls',freq,refPeriod1);
                    loc      = nb_ts.locateVariables(obsDates,newDates);
                end
                if newPeriods == 0
                    newPeriods = length(loc);
                end
                oldValues          = obj.data;
                if strcmpi(fill,'nan')
                    newValues = nan(newPeriods,obj.numberOfVariables,obj.numberOfDatasets);
                else
                    newValues = zeros(newPeriods,obj.numberOfVariables,obj.numberOfDatasets);
                end
                newValues(loc,:,:) = oldValues;
            else
                if ~ismember(freq,[4,12])
                    error([mfilename ':: The method ' method ' is only supported for monthly and quarterly data.'])
                end
                if strcmpi(method,'daverage')
                    newValues = nb_denton(obj.data,[],freq/oldFreq,'average',1);
                else
                    newValues = nb_denton(obj.data,[],freq/oldFreq,'sum',1);
                end
            end

            if interpolateLag > 0
                startDateNew = startDateNew - interpolateLag;
                endDateNew   = endDateNew - interpolateLag;
            end
            
            % Assign the properties
            obj.data      = newValues;
            obj.startDate = startDateNew;
            obj.endDate   = endDateNew;
            obj.frequency = obj.startDate.frequency;

        elseif strcmpi(method,'fill')

            % Force the "interpolation" date to be end (Which is 
            % the only sensible thing to do in this case.) 
            refPeriod = 0;
            
            % Here we do not interpolate. All data in between is
            % given by the same values
            switch freq 

                case 365
                    startDateNew = obj.startDate.getDay(1);
                    endDateNew   = obj.endDate.getDay(refPeriod);
                case 52
                    startDateNew = obj.startDate.getWeek(1);
                    endDateNew   = obj.endDate.getWeek(refPeriod);    
                case 12
                    startDateNew = obj.startDate.getMonth(1);
                    endDateNew   = obj.endDate.getMonth(refPeriod);
                case 4
                    startDateNew = obj.startDate.getQuarter(1);
                    endDateNew   = obj.endDate.getQuarter(refPeriod);
                case 2
                    startDateNew = obj.startDate.getHalfYear(1);
                    endDateNew   = obj.endDate.getHalfYear(refPeriod);
                otherwise
                    error([mfilename ':: Unsuported frequency ' int2str(freq)])
            end

            % Match the data and the dates
            newPeriods = endDateNew - startDateNew; 
            periods    = obj.endDate - obj.startDate;
            if freq == 52
                obsDatesObj = obj.startDate + (0:periods);
                obsDatesObj = obsDatesObj.getWeek(refPeriod);
                newDatesObj = startDateNew + (0:newPeriods);
                [~,loc]     = ismember(obsDatesObj,newDatesObj);
            else
                obsDates = obj.startDate.toDates(0:periods,'xls',obj.frequency,refPeriod);
                newDates = startDateNew.toDates(0:newPeriods,'xls',freq,refPeriod);
                loc      = nb_ts.locateVariables(obsDates,newDates);
            end
            oldValues          = obj.data;
            newValues          = nan(newPeriods,obj.numberOfVariables,obj.numberOfDatasets);
            newValues(loc,:,:) = oldValues;
            
            % Fill the wholes 
            switch freq

                case {365,52}

                    loc1 = 1;
                    for ii = 1:length(loc)
                        loc2    = loc(ii);
                        periods = loc2 - loc1;
                        for jj = 1:periods
                            newValues(loc(ii) - jj,:,:) = oldValues(ii,:,:);
                        end
                        loc1 = loc2 + 1;
                    end
                    
                otherwise

                    periods = freq/oldFreq - 1;
                    for ii = 1:periods
                        newValues(loc - ii,:,:) = oldValues;
                    end

            end

            if interpolateLag > 0
                startDateNew = startDateNew - interpolateLag;
                endDateNew   = endDateNew - interpolateLag;
            end
            
            % Assign the properties
            obj.data                 = newValues;
            obj.startDate            = startDateNew;
            obj.endDate              = endDateNew;
            obj.frequency            = obj.startDate.frequency;
            
        else
            
            if interpolateLag > 0
                error(['Setting the interpolateDate input to a scalar integer is not supported when ',...
                       'method input is set to ''' method '''.'])
            end
            
            warning('off','MATLAB:interp1:NaNstrip');

            switch freq 

                case 365

                    % Get the new start and end dates
                    startDateNew = obj.startDate.getDay(refPeriod1);
                    endDateNew   = obj.endDate.getDay(refPeriod2);

                    % Get the old values
                    oldValues    = obj.data;

                    % Do the interpolation
                    oPeriods    = nan(1,size(oldValues,1));
                    oPeriods(1) = 1;
                    for cc = 2:size(oldValues,1)
                        date          = obj.startDate + (cc - 1);
                        nrDays        = date.getNumberOfDays();
                        oPeriods(cc)  = oPeriods(cc - 1) + nrDays;
                    end

                    nPeriods = 1:endDateNew - startDateNew + 1;

                    newValues = interp1(oPeriods(1:end),oldValues(1:end,:,:),nPeriods,method); 
                    if obj.numberOfVariables == 1 && obj.numberOfDatasets == 1
                        newValues = newValues';
                    end 

                    % Correct series which ends before the others
                    corrected = isnan(oldValues(end,:,:));
                    if sum(corrected) > 0

                        indeces = find(corrected);

                        for cc = indeces

                            varValues = oldValues(:,cc,:);
                            isNaN     = isnan(varValues);
                            varValues = varValues(~isNaN);
                            endValue  = varValues(end);

                            varValuesNew = newValues(:,cc,:);
                            isNaNNew     = isnan(varValuesNew);
                            indicesNew   = find(~isNaNNew);
                            endIndexNew  = indicesNew(end) + 1;

                            newValues(endIndexNew,cc,:) = endValue;

                        end

                    end

                    % Assign the properties
                    obj.data      = newValues;
                    obj.startDate = startDateNew;
                    obj.endDate   = endDateNew;
                    obj.frequency = obj.startDate.frequency;

                case 52

                    % Get the new start and end dates
                    startDateNew = obj.startDate.getWeek(refPeriod1);
                    endDateNew   = obj.endDate.getWeek(refPeriod2);

                    % Get the old values
                    oldValues    = obj.data;

                    % Do the interpolation
                    oPeriods    = nan(1,size(oldValues,1));
                    oPeriods(1) = 1;
                    for cc = 2:size(oldValues,1)
                        date          = obj.startDate + (cc - 1);
                        nrWeeks       = date.getNumberOfWeeks();
                        oPeriods(cc)  = oPeriods(cc - 1) + nrWeeks;
                    end

                    nPeriods = 1:endDateNew - startDateNew + 1;

                    newValues = interp1(oPeriods,oldValues(1:end,:,:),nPeriods,method); 
                    if obj.numberOfVariables == 1 && obj.numberOfDatasets == 1
                        newValues = newValues';
                    end 

                    % Correct series which ends before the others
                    corrected = isnan(oldValues(end,:,:));
                    if sum(corrected) > 0

                        indeces = find(corrected);

                        for cc = indeces

                            varValues = oldValues(:,cc,:);
                            isNaN     = isnan(varValues);
                            varValues = varValues(~isNaN);
                            endValue  = varValues(end);

                            varValuesNew = newValues(:,cc,:);
                            isNaNNew     = isnan(varValuesNew);
                            indicesNew   = find(~isNaNNew);
                            endIndexNew  = indicesNew(end) + 1;

                            newValues(endIndexNew,cc,:) = endValue;

                        end

                    end

                    % Assign the properties
                    obj.data      = newValues;
                    obj.startDate = startDateNew;
                    obj.endDate   = endDateNew;
                    obj.frequency = obj.startDate.frequency;

                case {2,4,12}

                    % Do the interpolation
                    oldPeriods   = 1:(obj.endDate - obj.startDate + 1);
                    if freq == 12
                        startDateNew = obj.startDate.getMonth(refPeriod1);
                        endDateNew   = obj.endDate.getMonth(refPeriod2);
                    elseif freq == 4
                        startDateNew = obj.startDate.getQuarter(refPeriod1);
                        endDateNew   = obj.endDate.getQuarter(refPeriod2);
                    else
                        startDateNew = obj.startDate.getHalfYear(refPeriod1);
                        endDateNew   = obj.endDate.getHalfYear(refPeriod2);
                    end
                    periods       = 1:obj.frequency/freq:oldPeriods(end);
                    oldValues     = obj.data;
                    isNotNaN      = ~isnan(oldValues);
                    numNotMissing = sum(isNotNaN);
                    ind           = numNotMissing < 2;
                    if length(unique(numNotMissing(:))) ~= 1
                        % Each page and variable may have different number of missing
                        % observations
                        newValues = nan(size(periods,2),obj.numberOfVariables,obj.numberOfDatasets);
                        for ii = 1:obj.numberOfDatasets
                            for jj = 1:obj.numberOfVariables
                                last                  = find(isNotNaN(:,jj,ii),1,'last');
                                periods               = 1:obj.frequency/freq:oldPeriods(last);
                                newValuesTemp         = interp1(oldPeriods(1:last),oldValues(1:last,jj,ii),periods,method)';
                                tt                    = size(newValuesTemp,1);
                                newValues(1:tt,jj,ii) = newValuesTemp;
                            end
                        end
                    else
                        
                        if any(ind(:))
                            newValues = nan(size(periods,2),obj.numberOfVariables,obj.numberOfDatasets);
                            for ii = 1:obj.numberOfDatasets
                                newValuesTemp                 = interp1(oldPeriods,oldValues(:,~ind(:,:,ii),ii),periods,method);
                                newValues(:,~ind(:,:,ii),ii)  = newValuesTemp;
                                newValues(end,ind(:,:,ii),ii) = oldValues(end,ind(:,:,ii),ii);
                            end
                        else
                            newValues = interp1(oldPeriods,oldValues,periods,method);
                        end
                        
                        % Assign the properties
                        if obj.numberOfVariables == 1 && obj.numberOfDatasets == 1
                            newValues = newValues';
                        end 
                        
                        % Correct series which ends before the others
                        corrected = isnan(oldValues(end,:,:));
                        if sum(corrected(:)) > 0

                            for ii = 1:obj.numberOfDatasets

                                indeces = find(corrected(:,:,ii));
                                for cc = indeces

                                    varValues = oldValues(:,cc,ii);
                                    isNaN     = isnan(varValues);
                                    varValues = varValues(~isNaN);
                                    endValue  = varValues(end);

                                    varValuesNew = newValues(:,cc,ii);
                                    isNaNNew     = isnan(varValuesNew);
                                    indicesNew   = find(~isNaNNew);
                                    endIndexNew  = indicesNew(end) + 1;

                                    if endIndexNew <= size(newValues,1)
                                        newValues(endIndexNew,cc,ii) = endValue;
                                    end

                                end

                            end

                        end
                        
                    end
                    
                    obj.data      = newValues;
                    obj.startDate = startDateNew;
                    obj.endDate   = endDateNew;
                    obj.frequency = obj.startDate.frequency;
                    
                otherwise

                    error([mfilename ':: Unsupported frequency ' int2str(freq)])

            end
            
            warning('on','MATLAB:interp1:NaNstrip');

        end

    %--------------------------------------------------------------
    % Convert to lower frequency  
    %--------------------------------------------------------------
    else

        if strcmpi(method,'first')
            [~,locations] = obj.startDate.toDates(0:(obj.endDate - obj.startDate),'default',freq,1);
        else
            [~,locations] = obj.startDate.toDates(0:(obj.endDate - obj.startDate),'default',freq,0);
        end

        if ~isempty(locations)

            switch lower(method)

                case 'average'

                    if obj.frequency == 365
                        meanMethod = @nanmean;
                    else
                        meanMethod = @mean; 
                    end
                    
                    newData        = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    newData(1,:,:) = nanmean(obj.data(1:locations(1),:,:),1);
                    for mm = 2:length(locations)
                        newData(mm,:,:) = meanMethod(obj.data(locations(mm-1) + 1:locations(mm),:,:),1);
                    end

                    if strcmpi(includeLast,'on') && obj.numberOfObservations > locations(end)
                        meanData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                        dataTemp = meanMethod(obj.data(locations(end) + 1:end,:,:),1);
                        if ~isempty(dataTemp)
                            meanData(1,:,:) = dataTemp;
                        end
                        newData = [newData; meanData];
                    end
                    
                case {'diffaverage','diffsum'}
                    
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    if obj.frequency == 52
                        
                        newStartDate = obj.startDate + (locations(1) - 1);
                        switch freq
                            case 12
                                divFreq      = [4,5];
                                newStartDate = newStartDate.getMonth();
                            case 4
                                divFreq      = [12,13,14]; 
                                newStartDate = newStartDate.getQuarter();
                            case 2
                                divFreq      = [26,27];
                                newStartDate = newStartDate.getHalfYear();
                            case 1
                                divFreq      = [52,53];
                                newStartDate = newStartDate.getYear();
                        end
                        
                        weights  = cell(1,2);
                        numElem1 = nan(1,2);
                        for ii = 1:length(divFreq)
                            numElem1(ii) = divFreq(ii)*2 - 2;
                            weights1     = 1:divFreq(ii);
                            weights2     = divFreq(ii)-1:-1:1;
                            weights{ii}  = [weights1,weights2]';
                            if strcmpi(method,'diffaverage')
                                weights{ii} = weights{ii}/divFreq(ii); 
                            end
                        end
                        date     = newStartDate;
                        numWeeks = date.getNumberOfWeeks;
                        ind      = numWeeks == divFreq;
                        start    = find(locations > numElem1(ind),1);
                        if start > 1
                            date = date + (start - 1);
                        end
                        for mm = start:length(locations) 
                            numWeeks        = getNumberOfWeeks(date);
                            ind             = numWeeks == divFreq;
                            dataTemp        = obj.data(locations(mm)-numElem1(ind):locations(mm),:,:);
                            newData(mm,:,:) = sum(bsxfun(@times,dataTemp,weights{ind}),1);
                            date            = date + 1;
                        end
                        
                    else
                    
                        divFreq  = oldFreq/freq;
                        numElem1 = divFreq*2 - 2;
                        weights1 = 1:divFreq;
                        weights2 = divFreq-1:-1:1;
                        weights  = [weights1,weights2]';
                        if strcmpi(method,'diffaverage')
                            weights = weights/divFreq; 
                        end
                        start = find(locations > numElem1,1);
                        for mm = start:length(locations)
                            dataTemp        = obj.data(locations(mm)-numElem1:locations(mm),:,:);
                            newData(mm,:,:) = sum(bsxfun(@times,dataTemp,weights),1);
                        end
                        
                    end

                    if strcmpi(includeLast,'on') && obj.numberOfObservations > locations(end)
                        meanData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                        newData  = [newData; meanData];
                    end
                    
                case 'sum'
                    
                    if obj.frequency == 365
                        sumMethod = @nansum;
                    else
                        sumMethod = @sum; 
                    end
                    
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    for mm = 1:length(locations)

                        if mm == 1

                            for jj = 1:obj.numberOfVariables
                                for zz = 1:obj.numberOfDatasets
                                    dataTemp = obj.data(1:locations(mm),jj,zz);
                                    if ~isempty(dataTemp)
                                        newData(mm,jj,zz) = sumMethod(dataTemp,1);
                                    end
                                end
                            end

                        else

                            for jj = 1:obj.numberOfVariables
                                for zz = 1:obj.numberOfDatasets
                                    dataTemp = obj.data(locations(mm-1) + 1:locations(mm),jj,zz);
                                    if ~isempty(dataTemp)
                                        newData(mm,jj,zz) = sumMethod(dataTemp,1);
                                    end
                                end
                            end

                        end

                    end

                    if strcmpi(includeLast,'on') && obj.numberOfObservations > locations(end)

                        sumData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                        for jj = 1:obj.numberOfVariables
                            for zz = 1:obj.numberOfDatasets
                                dataTemp = obj.data(locations(end) + 1:end,jj,zz);
                                if ~isempty(dataTemp)
                                    sumData(1,jj,zz) = sumMethod(dataTemp,1);
                                end
                            end
                        end
                        newData = [newData; sumData];

                    end
                    
                case 'max'
                    
                    kk      = 1;
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    for mm = 1:length(locations)

                        if mm == 1
                            dataTemp        = obj.data(1:locations(mm),:,:);
                            newData(kk,:,:) = max(dataTemp,[],1);
                        else 
                            dataTemp        = obj.data(locations(mm-1) + 1:locations(mm),:,:);
                            newData(kk,:,:) = max(dataTemp,[],1);
                        end
                        kk = kk + 1;

                    end

                    if strcmpi(includeLast,'on') && obj.numberOfObservations > locations(end)
                        dataTemp = obj.data(locations(end) + 1:end,:,:);
                        minData  = max(dataTemp,[],1);
                        newData  = [newData; minData];
                    end        
                    
                case 'min'
                    
                    kk      = 1;
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    for mm = 1:length(locations)

                        if mm == 1
                            dataTemp        = obj.data(1:locations(mm),:,:);
                            newData(kk,:,:) = min(dataTemp,[],1);
                        else
                            dataTemp        = obj.data(locations(mm-1) + 1:locations(mm),:,:);
                            newData(kk,:,:) = min(dataTemp,[],1);
                        end
                        kk = kk + 1;

                    end

                    if strcmpi(includeLast,'on') && obj.numberOfObservations > locations(end)
                        dataTemp = obj.data(locations(end) + 1:end,:,:);
                        minData  = min(dataTemp,[],1);
                        newData  = [newData; minData];
                    end    

                case 'discrete'

                    kk      = 1;
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    for mm = 1:length(locations)

                        dataTemp = obj.data(locations(mm),:,:);
                        cc = 1;
                        
                        if obj.frequency == 365
                            try
                                % If we have daily data, the last day
                                % in the lower frequency can be a 
                                % workday, therfore we must try to look 
                                % for the last observation in the 
                                % subperiod
                                if mm == 1
                                    while all(isnan(dataTemp))
                                        dataTemp = obj.data(locations(mm) - cc,:,:);
                                        cc = cc + 1;
                                    end
                                else
                                    while all(isnan(dataTemp)) && locations(mm) - cc > locations(mm - 1)
                                        dataTemp = obj.data(locations(mm) - cc,:,:);
                                        cc = cc + 1;
                                    end
                                end
                                
                            catch %#ok<CTCH>
                                dataTemp = nan;
                            end
                        end
                        newData(kk,:,:) = dataTemp;

                        kk = kk + 1;

                    end

                    if strcmpi(includeLast,'on')
                        warning('nb_ts:convert:noOptionIncludeLastWhenDiscrete',[mfilename ':: No option ''includeLast'' when using the method ''discrete''.'])
                    end
                    
                case 'first'
                    
                    kk      = 1;
                    newData = nan(length(locations),obj.numberOfVariables,obj.numberOfDatasets);
                    for mm = 1:length(locations)

                        dataTemp        = obj.data(locations(mm),:,:);
                        cc = 1;
                        
                        if obj.frequency == 365
                            try
                                % If we have daily data, the first day
                                % in the lower frequency can be a 
                                % workday, therefore we must try to look 
                                % for the first observation in the 
                                % subperiod
                                if mm == length(locations)
                                    while isnan(dataTemp)
                                        dataTemp = obj.data(locations(mm) + cc,:,:);
                                        cc = cc + 1;
                                    end 
                                else
                                    while isnan(dataTemp) && locations(mm) + cc < locations(mm + 1)
                                        dataTemp = obj.data(locations(mm) + cc,:,:);
                                        cc = cc + 1;
                                    end
                                end
                                
                            catch %#ok<CTCH>
                                dataTemp = nan;
                            end
                        end
                        newData(kk,:,:) = dataTemp;

                        kk = kk + 1;

                    end

                    if strcmpi(includeLast,'on')
                        warning('nb_ts:convert:noOptionIncludeLastWhenFirst',[mfilename ':: No option ''includeLast'' when using the method ''first''.'])
                    end

                otherwise

                    error([mfilename ':: Unsupported method ' method ' when converting to a lower frequency.'])    
            end

            newStartDate = obj.startDate + (locations(1) - 1);
            switch freq
                case 52
                    newStartDate = newStartDate.getWeek();
                case 12
                    newStartDate = newStartDate.getMonth();
                case 4
                    newStartDate = newStartDate.getQuarter();
                case 2
                    newStartDate = newStartDate.getHalfYear();
                case 1
                    newStartDate = newStartDate.getYear();
            end
            obj.data      = newData;
            obj.frequency = freq;
            obj.startDate = newStartDate;
            obj.endDate   = newStartDate + (size(obj.data,1) - 1);

        else

            obj = obj.empty();

        end

    end

    % Rename the variables if wanted
    if strcmpi(rename,'on')

        switch oldFreq
            case 1
                f = 'A';
            case 2
                f = 'S';
            case 4
                f = 'Q';
            case 12
                f = 'M';
            case 52
                f = 'W';
            case 365
                f = 'D';
        end

        switch freq

            case 1
                t = 'A';
            case 2
                t = 'S';
            case 4
                t = 'Q';
            case 12
                t = 'M';
            case 52
                t = 'W';
            case 365
                t = 'D';
        end

        obj.variables = strrep(obj.variables,[f 'UA'],[t 'UA']);
        obj.variables = strrep(obj.variables,[f 'SA'],[t 'SA']);
        obj.variables = strrep(obj.variables,[f 'TA'],[t 'TA']);

    end
    
    if obj.isUpdateable() && ~obj.isBeingMerged
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@convert,[{freq,method},varargin]);
        
    end

end
