function varargout = toDates(obj,periods,format,newFreq,first)
% Syntax:
% 
% varargout = toDates(obj,periods,format,newFreq,first)
%
% Description:
%   
% Get a cellstr array of the dates ahead
%         
% Input:
% 
% - obj     : An object of class nb_day
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : Set the format of the cellstr of dates:
% 
%             > 'nb_date' : The output will be a vector of nb_date objects.
%
%             > 'default' : 'yyyyMm(m)Dd(d)'
% 
%             > 'fame'    : 'ddmonyyyy', e.g. '10jan2012'
% 
%             > 'xls'     : 'dd.mm.yyyy'
% 
%             > 'vintage' : 'yyyymmdd'
%
%             Formats which is dependent on the 'newFreq' input
%             > 'NBNorsk' ('NBNorwegian'): 
% 
%                 newFreq;
%                 > 1   : 'yyyy' 
%                 > 2   : 'mmm. yy', e.g. 'jan. 08' and 'jul. 08' 
%                 > 4   : 'q.kv.yy' 
%                 > 12  : 'mmm. yy', e.g. mmm = 'jan'
%                 > 52  : 'Ukew(w)-yy'
%                 > 365 : 'dd.mm.yyyy'
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
%             > 'NBEnglish' ('NBEngelsk'):
% 
%                 newFreq;
%                 > 1   : 'yyyy' 
%                 > 2   : 'mmm-yy', e.g. 'jan. 08' and 'jul. 08' 
%                 > 4   : 'yyyyQq' 
%                 > 12  : 'mmm-yy', e.g. mmm = 'jan'
%                 > 52  : 'Weekw(w)-yy'  
%                 > 365 : 'dd.mm.yyyy'
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
% - newFreq  : > 1   : yearly
%              > 2   : semiannually
%              > 4   : quarterly
%              > 12  : monthly
%              > 365 : daily
% 
% - first    : When converting to a lower frequency you must set if
%              you want to use the first date or the last date as 
%              the location of the returned date. The default is to
%              use the first.
% 
%              1 = first
%              0 = last
% 
% Output:
% 
% - varargout{1} : A cell array of the wanted dates.
% 
% - varargout{2} : Locations of the returned dates. Of interest 
%                  when converting to lower frequencies
% 
% Examples:
%
% obj               = nb_day(1,1,2000);
% dates             = obj.toDates(0:2000);
% dates             = obj.toDates(0:2000,'xls');
% dates             = obj.toDates(0:2000,'nb_date',12)
% [dates,locations] = obj.toDates(0:2000,'NBNorsk',1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 365; 
            if nargin < 3
                format = 'default';
                
            end
        end
    end
    if ~(newFreq == 365) && strcmp(format,'nb_day')
        error('Wrong frequency. Must be 365')
        
    end

    if ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    end

    try

        maxPer = max(periods);
        minPer = min(periods);

        if minPer < 0 && maxPer < 0

            numPer        = -minPer;
            periodsAhead  = 0;
            periodsBackW  = -minPer;

        elseif minPer < 0

            numPer       = -minPer + maxPer + 1;
            periodsAhead = maxPer;
            periodsBackW = -minPer;

        else
            numPer       = maxPer;
            periodsAhead = maxPer;
            periodsBackW = 0;
        end

        days   = zeros(numPer,1);
        months = zeros(numPer,1);
        years  = zeros(numPer,1);

        % Get the current period if included
        if sum(minPer:maxPer == 0)
            currentPer = 1;
            days(currentPer + periodsBackW)   = obj.day;
            months(currentPer + periodsBackW) = obj.month;
            years(currentPer + periodsBackW)  = obj.year;
        else
            currentPer = 0;
        end

        % Find the periods ahead
        m         = obj.month;
        y         = obj.year;
        d         = obj.day;
        for ii = 1:periodsAhead

            d = d + 1;
            switch m
                case {1,3,5,7,8,10}
                    if d == 32
                        d = 1;
                        m = m + 1;
                    end
                case {4,6,9,11}
                    if d == 31
                        d = 1;
                        m = m + 1;
                    end
                case 2
                    switch nb_year(y).leapYear
                        case 1
                            if d == 30 
                                d = 1;
                                m = 3;
                            end
                        case 0
                            if d == 29 
                                d = 1;
                                m = 3;
                            end
                    end
                case 12
                    if d == 32
                        d = 1;
                        m = 1;
                        y = y  + 1;
                    end
            end

            days(ii + currentPer + periodsBackW,1)   = d;
            months(ii + currentPer + periodsBackW,1) = m;
            years(ii + currentPer + periodsBackW,1)  = y;

        end

        % Find the periods backwards
        m         = obj.month;
        y         = obj.year;
        d         = obj.day;    
        for ii = 1:periodsBackW

            d = d - 1;
            if d == 0
                switch m
                    case {2,4,6,8,9,11}
                        d = 31;
                        m = m - 1;
                    case {5,7,10,12}
                        d = 30;
                        m = m - 1;
                    case 3
                        switch nb_year(y).leapYear
                            case 1
                                d = 29;
                                m = 2;
                            case 0
                                d = 28;
                                m = 2;
                        end
                    case 1
                        d = 31;
                        m = 12;
                        y = y  - 1;
                end
            end

            days(periodsBackW - ii + 1)   = d;
            months(periodsBackW - ii + 1) = m;
            years(periodsBackW - ii + 1)  = y;
        end

        % Shrink to the wanted dates
        if minPer <= 0 
            indCorrection = -minPer + 1;
        else
            indCorrection = 0;
        end

        days   = days(periods + indCorrection);
        months = months(periods  + indCorrection);
        years  = years(periods  + indCorrection);

        % Create date strings
        if ~isempty(days)

            switch newFreq

                case 1

                    % Find the dates
                    firstYear = obj.getYear();
                    lastDate  = obj + periods(end);
                    lastYear  = lastDate.getYear();
                    periods   = lastYear - firstYear;

                    if first
                        day1      = firstYear.getDay(first);
                        if obj ~= day1
                            dates     = firstYear.toDates(1:periods,format);
                            firstYear = firstYear + 1;
                        else
                            dates = firstYear.toDates(0:periods,format);
                        end
                    else
                        dates = firstYear.toDates(0:periods,format);
                    end

                    if first == 0
                        testDate = lastYear.getDay(first).toString();
                        per      = lastDate - testDate;
                        if per < 0
                            dates        = dates(1:end - 1);
                            lastYear = lastYear - 1;
                        end
                    end

                    % Find the locations
                    if nargout == 2

                        datesYear    = firstYear:lastYear;
                        datesDefault = obj:lastDate;
                        endDays      = cell(size(datesYear));
                        for ii = 1:length(datesYear)

                            yearT       = nb_year(datesYear{ii});
                            endDays{ii} = yearT.getDay(first).toString();

                        end

                        locations = nb_ts.locateVariables(endDays,datesDefault);

                    end

                    % Give the outputs
                    if nargout == 1
                        varargout{1} = dates;
                    elseif nargout == 2
                        varargout{1} = dates;
                        varargout{2} = locations;
                    elseif nargout == 0
                        varargout{1} = dates;
                    else
                        error([mfilename ':: To many output arguments'])
                    end

                case 2

                    % Find the dates
                    firstHalfYear = obj.getHalfYear();
                    lastDate      = obj + periods(end);
                    lastHalfYear  = lastDate.getHalfYear();
                    periods       = lastHalfYear - firstHalfYear;

                    if first
                        day1      = firstHalfYear.getDay(first);
                        if obj ~= day1
                            dates = firstHalfYear.toDates(1:periods,format);
                            firstHalfYear = firstHalfYear + 1;
                        else
                            dates = firstHalfYear.toDates(0:periods,format);
                        end
                    else
                        dates = firstHalfYear.toDates(0:periods,format);
                    end

                    if first == 0
                        testDate = lastHalfYear.getDay(first).toString();
                        per      = lastDate - testDate;
                        if per < 0
                            dates        = dates(1:end - 1);
                            lastHalfYear = lastHalfYear - 1;
                        end
                    end

                    % Find the locations
                    if nargout == 2

                        datesHalfYear = firstHalfYear:lastHalfYear;
                        datesDefault  = obj:lastDate;
                        endDays       = cell(size(datesHalfYear));
                        for ii = 1:length(datesHalfYear)

                            halfYearT    = nb_semiAnnual(datesHalfYear{ii});
                            endDays{ii}  = halfYearT.getDay(first).toString();

                        end

                        locations = nb_ts.locateVariables(endDays,datesDefault);

                    end

                    % Give the outputs
                    if nargout == 1
                        varargout{1} = dates;
                    elseif nargout == 2
                        varargout{1} = dates;
                        varargout{2} = locations;
                    elseif nargout == 0
                        varargout{1} = dates;
                    else
                        error([mfilename ':: To many output arguments'])
                    end

                case 4

                    % Find the dates
                    firstQuarter = obj.getQuarter();
                    lastDate     = obj + periods(end);
                    lastQuarter  = lastDate.getQuarter();
                    periods      = lastQuarter - firstQuarter;

                    if first
                        day1      = firstQuarter.getDay(first);
                        if obj ~= day1
                            dates = firstQuarter.toDates(1:periods,format);
                            firstQuarter = firstQuarter + 1;
                        else
                            dates = firstQuarter.toDates(0:periods,format);
                        end
                    else
                        dates = firstQuarter.toDates(0:periods,format);
                    end

                    if first == 0
                        testDate = lastQuarter.getDay(first).toString();
                        per      = lastDate - testDate;
                        if per < 0
                            dates       = dates(1:end - 1);
                            lastQuarter = lastQuarter - 1;
                        end
                    end

                    % Find the locations
                    if nargout == 2

                        datesQuarter = firstQuarter:lastQuarter;
                        datesDefault = obj:lastDate;
                        endDays      = cell(size(datesQuarter));
                        for ii = 1:length(datesQuarter)

                            quarterT    = nb_quarter(datesQuarter{ii});
                            endDays{ii} = quarterT.getDay(first).toString();

                        end

                        locations = nb_ts.locateVariables(endDays,datesDefault);

                    end

                    % Give the outputs
                    if nargout == 1
                        varargout{1} = dates;
                    elseif nargout == 2
                        varargout{1} = dates;
                        varargout{2} = locations;
                    elseif nargout == 0
                        varargout{1} = dates;
                    else
                        error([mfilename ':: To many output arguments'])
                    end

                case 12

                    % Find the dates
                    firstMonth = obj.getMonth();
                    lastDate   = obj + periods(end);
                    lastMonth  = lastDate.getMonth();
                    periods    = lastMonth - firstMonth;

                    if first
                        day1      = firstMonth.getDay(first);
                        if obj ~= day1
                            dates      = firstMonth.toDates(1:periods,format);
                            firstMonth = firstMonth + 1;
                        else
                            dates = firstMonth.toDates(0:periods,format);
                        end
                    else
                        dates = firstMonth.toDates(0:periods,format);
                    end

                    if first == 0
                        testDate = lastMonth.getDay(first).toString();
                        per      = lastDate - testDate;
                        if per < 0
                            dates     = dates(1:end - 1);
                            lastMonth = lastMonth - 1;
                        end
                    end 

                    % Find the locations
                    if nargout == 2

                        datesMonth   = firstMonth:lastMonth;
                        datesDefault = obj:lastDate;
                        endDays      = cell(size(datesMonth));
                        for ii = 1:length(datesMonth)

                            monthT      = nb_month(datesMonth{ii});
                            endDays{ii} = monthT.getDay(first).toString();

                        end

                        locations = nb_ts.locateVariables(endDays,datesDefault);

                    end

                    % Give the outputs
                    if nargout == 1
                        varargout{1} = dates;
                    elseif nargout == 2
                        varargout{1} = dates;
                        varargout{2} = locations;
                    elseif nargout == 0
                        varargout{1} = dates;
                    else
                        error([mfilename ':: To many output arguments'])
                    end
                    
                case 52
                    
                    % Find the dates
                    firstWeek  = obj.getWeek();
                    lastDate   = obj + periods(end);
                    lastWeek   = lastDate.getWeek();
                    periods    = lastWeek - firstWeek;

                    if first
                        day1 = firstWeek.getDay(first);
                        if obj ~= day1
                            dates     = firstWeek.toDates(1:periods,format);
                            firstWeek = firstWeek + 1;
                        else
                            dates = firstWeek.toDates(0:periods,format);
                        end
                    else
                        dates = firstWeek.toDates(0:periods,format);
                    end

                    if first == 0
                        testDate = toString(lastWeek.getDay(first));
                        per      = lastDate - testDate;
                        if per < 0
                            dates    = dates(1:end - 1);
                            lastWeek = lastWeek - 1;
                        end
                    end

                    % Find the locations
                    if nargout == 2

                        datesWeek    = firstWeek:lastWeek;
                        datesDefault = obj:lastDate;
                        endDays      = cell(size(datesWeek));
                        for ii = 1:length(datesWeek)

                            weekT       = nb_week(datesWeek{ii});
                            endDays{ii} = toString(weekT.getDay(first));

                        end

                        locations = nb_ts.locateVariables(endDays,datesDefault);

                    end

                    % Give the outputs
                    if nargout == 1
                        varargout{1} = dates;
                    elseif nargout == 2
                        varargout{1} = dates;
                        varargout{2} = locations;
                    elseif nargout == 0
                        varargout{1} = dates;
                    else
                        error([mfilename ':: To many output arguments'])
                    end

                case 365

                    if ~(strcmpi(format,'fame') || strcmpi(format,'nb_date'))

                        monthInd = months <= 9;
                        dayInd   = days   <= 9;

                        ind1 = dayInd & monthInd;
                        ind2 = ~dayInd & ~monthInd;
                        ind3 = ~dayInd & monthInd;
                        ind4 = dayInd & ~monthInd;

                    end

                    switch lower(format)
                        
                        case 'nb_date'
                            
                            dates(length(periods),1) = nb_day();
                            for ii = 1:length(periods)
                               dates(ii)           = nb_day(days(ii),months(ii),years(ii));
                               dates(ii).dayOfWeek = obj.dayOfWeek;
                            end
                        
                        case 'default' % format 'yyyyMm(m)Dd(d)'

                            freqSign1 = 'M';
                            freqSign2 = 'D';

                            dates1 = strcat(int2str(years(ind1))  , freqSign1,int2str(months(ind1)) , freqSign2,int2str(days(ind1)));
                            dates2 = strcat(int2str(years(ind2))  , freqSign1,int2str(months(ind2)) , freqSign2,int2str(days(ind2)));
                            dates3 = strcat(int2str(years(ind3))  , freqSign1,int2str(months(ind3)) , freqSign2,int2str(days(ind3)));
                            dates4 = strcat(int2str(years(ind4))  , freqSign1,int2str(months(ind4)) , freqSign2,int2str(days(ind4))); 

                        case {'xls','nbnorsk','nbnorwegian','nbengelsk','nbenglish'} % format 'dd.mm.yyyy'

                            extraString1 = '.';
                            extraString2 = '0';
                            extraString3 = '.0';

                            dates1 = strcat( extraString2, int2str(days(ind1)) ,extraString3, int2str(months(ind1)), extraString1, int2str(years(ind1)));
                            dates2 = strcat(               int2str(days(ind2)) ,extraString1, int2str(months(ind2)), extraString1, int2str(years(ind2)));
                            dates3 = strcat(               int2str(days(ind3)) ,extraString3, int2str(months(ind3)), extraString1, int2str(years(ind3)));
                            dates4 = strcat( extraString2, int2str(days(ind4)) ,extraString1, int2str(months(ind4)), extraString1, int2str(years(ind4)));

                        case {'vintage'} % format 'yyyymmdd'

                            extraString1 = '0';

                            dates1 = strcat( int2str(years(ind1)), extraString1, int2str(months(ind1)), extraString1, int2str(days(ind1)));
                            dates2 = strcat( int2str(years(ind2)), int2str(months(ind2)), int2str(days(ind2)));
                            dates3 = strcat( int2str(years(ind3)), extraString1, int2str(months(ind3)), int2str(days(ind3)));
                            dates4 = strcat( int2str(years(ind4)), int2str(months(ind4)), extraString1, int2str(days(ind4)));    
                            
                        case 'fame'

                            months = int2str(months);
                            months = strtrim(cellstr(months));
                            months = strrep(months,'10','oct');
                            months = strrep(months,'11','nov');
                            months = strrep(months,'12','dec');
                            months = strrep(months,'1','jan');
                            months = strrep(months,'2','feb');
                            months = strrep(months,'3','mar');
                            months = strrep(months,'4','apr');
                            months = strrep(months,'5','may');
                            months = strrep(months,'6','jun');
                            months = strrep(months,'7','jul');
                            months = strrep(months,'8','aug');
                            months = strrep(months,'9','sep');
                            months = char(months);

                            ind    = days   <= 9;

                            dates1 = strcat('0', int2str(days(ind)) , months(ind,:), int2str(years(ind)));
                            dates2 = strcat(     int2str(days(~ind)) , months(~ind,:), int2str(years(~ind)));

                            dates1 = cellstr(dates1);
                            dates2 = cellstr(dates2);

                            % Reorder the dates
                            dates       = cell(size(days,1),1);
                            dates(ind)  = dates1;
                            dates(~ind) = dates2;

                        otherwise

                            error([mfilename ':: Unsupported format; ' format])

                    end

                    if ~(strcmpi(format,'fame') || strcmpi(format,'nb_date'))

                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);
                        dates3 = cellstr(dates3);
                        dates4 = cellstr(dates4);

                        % Reorder the dates
                        dates       = cell(size(days,1),1);
                        dates(ind1) = dates1;
                        dates(ind2) = dates2;
                        dates(ind3) = dates3;
                        dates(ind4) = dates4;

                    end

                    % Give the outputs
                    if strcmpi(format,'nb_date')
                        if nargout == 1
                            varargout{1} = dates; 
                        elseif nargout == 2
                            varargout{1} = dates; 
                            varargout{2} = periods + 1; % Locations
                        elseif nargout == 0
                            varargout{1} = dates;
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                    else
                        if nargout == 1
                            varargout{1} = dates(~cellfun(@isempty,dates)); % Strip empty cells (because some of the indXs are empty)
                        elseif nargout == 2
                            varargout{1} = dates(~cellfun(@isempty,dates)); % Strip empty cells (because some of the indXs are empty)
                            varargout{2} = periods + 1; % Locations
                        elseif nargout == 0
                            varargout{1} = dates(~cellfun(@isempty,dates)); % Strip empty cells (because some of the indXs are empty)
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                    end

                otherwise

                    error([mfilename ':: Unsupported frequency; ' int2str(newFreq)])

            end

        end

    catch Err

        if isempty(periods)
            error([mfilename ':: The input ''periods'' is empty, but it must be double (vector). E.g. -10:10.'])
        else
            rethrow(Err);
        end

    end

end
