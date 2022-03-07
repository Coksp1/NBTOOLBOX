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
% - obj     : An object of class nb_week
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : Set the format of the cellstr of dates:
% 
%             > 'nb_date' : The output will be a vector of nb_date objects.
%
%             > 'default' : 'yyyyWw(w)'
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
%                 > 52  : 'Uke w(w)-yy'
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
%                 > 52  : 'Week w(w)-yy'  
%                 > 365 : 'dd.mm.yyyy'
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
% - newFreq  : > 1   : yearly
%              > 2   : semiannually
%              > 4   : quarterly
%              > 12  : monthly
%              > 52  : weekly
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
% dates             = obj.toDates(0:2000);
% dates             = obj.toDates(0:2000,'xls');
% [dates,locations] = obj.toDates(0:2000,'NBNorsk',1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 52; 
            if nargin < 3
                format = 'default';

            end
        end
    end
    
    if ~(newFreq == 52) && strcmp(format,'nb_week')
        error('Wrong frequency. Must be 52')
        
    end
    if ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    elseif isempty(periods)
        error([mfilename ':: The input ''periods'' can not be empty.'])
    end
    freqSign  = 'W';

    % Get the week and year of each element
    periods = periods(:);
    nPer    = length(periods);
    last    = 0;
    week    = obj.week;
    year    = obj.year;
    years  = nan(nPer,1);
    weeks  = years;
    for ii = 1:nPer
        [week,year] = nb_week.localplus(week,year,periods(ii) - last);
        weeks(ii)   = week;
        years(ii)   = year;
        last        = periods(ii);
    end
    
    % Convert double to cellstr
    %--------------------------------------------------------------
    if ~isempty(years) && ~isempty(weeks)

        switch newFreq

            case 1

                % Find the dates
                firstYear = obj.getYear();
                lastDate  = obj + periods(end);
                lastYear  = lastDate.getYear();
                periods   = lastYear - firstYear;
                
                if first
                    week1 = firstYear.getWeek(first);
                    if obj ~= week1
                        dates     = firstYear.toDates(1:periods,format);
                        firstYear = firstYear + 1;
                    else
                        dates = firstYear.toDates(0:periods,format);
                    end
                else
                    dates    = firstYear.toDates(0:periods,format);
                    testDate = lastYear.getWeek(first);
                    per      = lastDate - testDate;
                    if per < 0
                        dates    = dates(1:end - 1);
                        lastYear = lastYear - 1;
                    end
                    testDate = firstYear.getWeek(first);
                    per      = obj - testDate;
                    if per > 0
                        dates     = dates(2:end);
                        firstYear = firstYear + 1;
                    end
                end
                
                % Find the locations
                if nargout == 2

                    datesYear    = firstYear:lastYear;
                    datesDefault = obj:lastDate;
                    endDays      = cell(size(datesYear));
                    for ii = 1:length(datesYear)
                        yearT       = nb_year(datesYear{ii});
                        endDays{ii} = yearT.getWeek(first).toString();
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
                    week1 = firstHalfYear.getWeek(first);
                    if obj ~= week1
                        dates         = firstHalfYear.toDates(1:periods,format);
                        firstHalfYear = firstHalfYear + 1;
                    else
                        dates = firstHalfYear.toDates(0:periods,format);
                    end
                else
                    dates    = firstHalfYear.toDates(0:periods,format);
                    testDate = lastHalfYear.getWeek(first);
                    per      = lastDate - testDate;
                    if per < 0
                        dates        = dates(1:end - 1);
                        lastHalfYear = lastHalfYear - 1;
                    end
                    testDate = firstHalfYear.getWeek(first);
                    per      = obj - testDate;
                    if per > 0
                        dates         = dates(2:end);
                        firstHalfYear = firstHalfYear + 1;
                    end
                end

                % Find the locations
                if nargout == 2

                    datesHalfYear = firstHalfYear:lastHalfYear;
                    datesDefault  = obj:lastDate;
                    endDays       = cell(size(datesHalfYear));
                    for ii = 1:length(datesHalfYear)
                        halfYearT    = nb_semiAnnual(datesHalfYear{ii});
                        endDays{ii}  = halfYearT.getWeek(first).toString();
                    end

                    try
                        locations = nb_ts.locateVariables(endDays,datesDefault);
                    catch 
                        locations = nb_ts.locateVariables(endDays(1:end-1),datesDefault);
                        dates     = dates(1:end-1);
                    end

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
                    week1 = firstQuarter.getWeek(first);
                    if obj ~= week1
                        dates        = firstQuarter.toDates(1:periods,format);
                        firstQuarter = firstQuarter + 1;
                    else
                        dates = firstQuarter.toDates(0:periods,format);
                    end
                else
                    dates    = firstQuarter.toDates(0:periods,format);
                    testDate = lastQuarter.getWeek(first);
                    per      = lastDate - testDate;
                    if per < 0
                        dates       = dates(1:end - 1);
                        lastQuarter = lastQuarter - 1;
                    end
                    testDate = firstQuarter.getWeek(first);
                    per      = obj - testDate;
                    if per > 0
                        dates        = dates(2:end);
                        firstQuarter = firstQuarter + 1;
                    end
                end
                
                % Find the locations
                if nargout == 2

                    datesQuarter = firstQuarter:lastQuarter;
                    datesDefault = obj:lastDate;
                    endDays      = cell(size(datesQuarter));
                    for ii = 1:length(datesQuarter)

                        quarterT    = nb_quarter(datesQuarter{ii});
                        endDays{ii} = quarterT.getWeek(first).toString();

                    end

                    try
                        locations = nb_ts.locateVariables(endDays,datesDefault);
                    catch
                        locations = nb_ts.locateVariables(endDays(1:end-1),datesDefault);
                        dates     = dates(1:end-1);
                    end

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
                    week1 = firstMonth.getWeek(first);
                    if obj ~= week1
                        dates      = firstMonth.toDates(1:periods,format);
                        firstMonth = firstMonth + 1;
                    else
                        dates = firstMonth.toDates(0:periods,format);
                    end
                else
                    dates    = firstMonth.toDates(0:periods,format);
                    testDate = lastMonth.getWeek(first);
                    per      = lastDate - testDate;
                    if per < 0
                        dates     = dates(1:end - 1);
                        lastMonth = lastMonth - 1;
                    end
                    testDate = firstMonth.getWeek(first);
                    per      = obj - testDate;
                    if per > 0
                        dates      = dates(2:end);
                        firstMonth = firstMonth + 1;
                    end
                end

                % Find the locations
                if nargout == 2

                    datesMonth   = firstMonth:lastMonth;
                    datesDefault = obj:lastDate;
                    endDays      = cell(size(datesMonth));
                    for ii = 1:length(datesMonth)

                        monthT      = nb_month(datesMonth{ii});
                        endDays{ii} = monthT.getWeek(first).toString();

                    end

                    try
                        locations = nb_ts.locateVariables(endDays,datesDefault);
                    catch 
                        locations = nb_ts.locateVariables(endDays(1:end-1),datesDefault);
                        dates     = dates(1:end-1);
                    end

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
                
                switch lower(format)
                    
                    case 'nb_date'
                        
                        dates(length(periods),1) = nb_week();
                        for ii = 1:length(periods)
                            dates(ii)           = nb_week(weeks(ii),years(ii),obj.dayOfWeek);
                            dates(ii).dayOfWeek = obj.dayOfWeek;
                        end
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
                        
                    case {'default','fame'}
                        
                        weekInd = weeks <= 9;
                        
                        dates1 = strcat(int2str(years(weekInd)), freqSign,int2str(weeks(weekInd)));
                        dates2 = strcat(int2str(years(~weekInd)),freqSign,int2str(weeks(~weekInd)));
                        
                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);
                        
                        % Reorder the dates
                        cellOfDates           = cell(size(dates1,1) + size(dates2,1),1);
                        cellOfDates(weekInd)  = dates1;
                        cellOfDates(~weekInd) = dates2;
                        
                        % Strip empty cells (because some of the indXs are empty)
                        if nargout == 1
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        elseif nargout == 2
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                        
                    case {'xls','vintage'}
                        
                        cellOfDates = nb_week.getXLSDate(weeks,obj.dayOfWeek,years,0);
                        if strcmpi(format,'vintage')
                            charOfDates = char(cellOfDates);
                            charOfDates = [charOfDates(:,7:10),charOfDates(:,4:5),charOfDates(:,1:2)];
                            cellOfDates = cellstr(charOfDates);
                        end
                        
                        % Strip empty cells (because som of the indXs are empty)
                        if nargout == 1
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        elseif nargout == 2
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                        
                    case {'nbnorsk','nbnorwegian'}
                        
                        weekInd = weeks <= 9;
                        
                        yearsStr = int2str(years);
                        
                        dates1 = strcat({'Uke '},int2str(weeks(weekInd)),{'-'}, yearsStr(weekInd,3:4));
                        dates2 = strcat({'Uke '},int2str(weeks(~weekInd)),{'-'}, yearsStr(~weekInd,3:4));
                        
                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);
                        
                        % Reorder the dates
                        cellOfDates           = cell(size(dates1,1) + size(dates2,1),1);
                        cellOfDates(weekInd)  = dates1;
                        cellOfDates(~weekInd) = dates2;
                        
                        % Give the outputs
                        if nargout == 1
                            varargout{1} = cellstr(cellOfDates);
                        elseif nargout == 2
                            varargout{1} = cellstr(cellOfDates);
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellstr(cellOfDates);
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                        
                    case {'nbengelsk','nbenglish'}
                        
                        weekInd = weeks <= 9;
                        
                        yearsStr = int2str(years);
                        
                        dates1 = strcat({'Week '},int2str(weeks(weekInd)),{'-'}, yearsStr(weekInd,3:4));
                        dates2 = strcat({'Week '},int2str(weeks(~weekInd)),{'-'}, yearsStr(~weekInd,3:4));
                        
                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);
                        
                        % Reorder the dates
                        cellOfDates           = cell(size(dates1,1) + size(dates2,1),1);
                        cellOfDates(weekInd)  = dates1;
                        cellOfDates(~weekInd) = dates2;
                        
                        % Give the outputs
                        if nargout == 1
                            varargout{1} = cellstr(cellOfDates);
                        elseif nargout == 2
                            varargout{1} = cellstr(cellOfDates);
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellstr(cellOfDates);
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                        
                    otherwise
                        error([mfilename ':: Unsupported date format; ' format])
                end

            case 365

                error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                                 'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

            otherwise

                error([mfilename ':: Unsupported frequency; ' int2str(newFreq)])

        end
        
    end

end
