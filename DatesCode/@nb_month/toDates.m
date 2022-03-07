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
% - obj     : An object of class nb_month
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : Set the format of the cellstr of dates:
% 
%             > 'nb_date' : The output will be a vector of nb_date objects.
%
%             > 'default' : 'yyyyMm(m)'
% 
%             > 'fame'    : 'yyyyMm(m)'
% 
%             > 'xls'     : 'dd.mm.yyyy'
%
%             > 'vintage' : 'yyyymmdd'
% 
%             Formats which is dependent on the 'newFreq' input
%             > 'NBNorsk' ('NBNorwegian'): 
% 
%                 newFreq:
%                 > 1   : 'yyyy' 
%                 > 2   : 'mmm. yy', e.g. 'jan. 08' and 'jul. 08' 
%                 > 4   : 'q.kv.yy' 
%                 > 12  : 'mmm. yy', e.g. mmm = 'jan'
%                 > 52  : Not possible
%                 > 365 : Not possible
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
%             > 'NBEnglish' ('NBEngelsk'):
% 
%                 newFreq:
%                 > 1   : 'yyyy' 
%                 > 2   : 'mmm-yy', e.g. 'jan. 08' and 'jul. 08' 
%                 > 4   : 'yyyyQq' 
%                 > 12  : 'mmm-yy', e.g. mmm = 'jan'
%                 > 52  : Not possible
%                 > 365 : Not possible
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
% - newFreq  : > 1   : yearly
%              > 2   : semiannually 
%              > 4   : quarterly
%              > 12  : monthly 
%              > 52  : weekly        (Not possible)
%              > 365 : daily         (Not possible)
% 
% - first    : When converting to a lower frequency you must set if
%              you want to use the first date or the last date as 
%              the location of the returned date. The default is to
%              use the first.
% 
%              1 : first
%              0 : last
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
% dates             = obj.toDates(0:20);
% dates             = obj.toDates(0:20,'xls');
% [dates,locations] = obj.toDates(0:20,'NBNorsk',1);
%  
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 12;
            if nargin < 3
                format = 'default';

            end
        end
    end
    if ~(newFreq == 12) && strcmp(format,'nb_month')
        error('Wrong frequency. Must be 12')
        
    end
    if isempty(periods) 
        error([mfilename ':: The input ''periods'' is empty, but it must be double (vector). E.g. -10:10.'])
    elseif ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    end

    periods           = periods(:);
    SampleStartMonth  = obj.month;
    SampleStartYear   = obj.year;
    freqSign          = 'M';

    years    = floor((periods + SampleStartMonth - 1)/12 + SampleStartYear);
    months   = SampleStartMonth + periods - (years - SampleStartYear)*12;

    if ~isempty(years) && ~isempty(months)

        switch newFreq

            case 1

                % Find the dates
                firstYear = obj.getYear();
                lastDate  = obj + periods(end);
                lastYear  = lastDate.getYear();
                periods   = lastYear - firstYear;

                if first
                    month1    = firstYear.getMonth(first);
                    if obj ~= month1
                        dates = firstYear.toDates(1:periods,format);
                        firstYear = firstYear + 1;
                    else
                        dates = firstYear.toDates(0:periods,format);
                    end
                else
                    dates = firstYear.toDates(0:periods,format);
                end

                if first == 0
                    testDate = lastYear.getMonth(first).toString();
                    per      = lastDate - testDate;
                    if per < 0
                        dates    = dates(1:end - 1);
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
                        endDays{ii} = yearT.getMonth(first).toString();

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
                    month1        = firstHalfYear.getMonth(first);
                    if obj ~= month1
                        dates = firstHalfYear.toDates(1:periods,format);
                        firstHalfYear = firstHalfYear + 1;
                    else
                        dates = firstHalfYear.toDates(0:periods,format);
                    end
                else
                    dates = firstHalfYear.toDates(0:periods,format);
                end

                if first == 0
                    testDate = lastHalfYear.getMonth(first).toString();
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
                        endDays{ii}  = halfYearT.getMonth(first).toString();

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
                    month1       = firstQuarter.getMonth(first);
                    if obj ~= month1
                        dates = firstQuarter.toDates(1:periods,format);
                        firstQuarter = firstQuarter + 1;
                    else
                        dates = firstQuarter.toDates(0:periods,format);
                    end
                else
                    dates = firstQuarter.toDates(0:periods,format);
                end

                if first == 0
                    testDate = lastQuarter.getMonth(first).toString();
                    per      = lastDate - testDate;
                    if per < 0
                        dates        = dates(1:end - 1);
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
                        endDays{ii} = quarterT.getMonth(first).toString();

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

                switch lower(format)

                    case 'nb_date'
                        
                        dates(length(periods),1) = nb_month();
                        for ii = 1:length(periods)
                            dates(ii)           = nb_month(months(ii),years(ii));
                            dates(ii).dayOfWeek = obj.dayOfWeek;
                        end
                        
                        % Give the outputs
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

                        monthInd = months <= 9; 

                        dates1 = strcat(int2str(years(monthInd)), freqSign,int2str(months(monthInd)));
                        dates2 = strcat(int2str(years(~monthInd)),freqSign,int2str(months(~monthInd)));

                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);

                        % Reorder the dates
                        cellOfDates            = cell(size(dates1,1) + size(dates2,1),1);
                        cellOfDates(monthInd)  = dates1;
                        cellOfDates(~monthInd) = dates2;

                        % Strip empty cells (because som of the indXs are empty)
                        if nargout == 1
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        elseif nargout == 2
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellOfDates;    
                        else
                            error([mfilename ':: To many output arguments'])
                        end

                    case {'xls','vintages'}

                        if first
                            first  = zeros(size(months,1),1);
                            second = ones(size(months,1),1);
                            days   = strcat(int2str(first),int2str(second));
                        else
                            monthObjs = nb_month.toCellOfObjects(months,years);
                            days      = cellfun(@getNumberOfDays,monthObjs);
                            days      = int2str(days);
                        end

                        ind1 = months <= 9;
                        ind2 = ~ind1;

                        if strcmpi(format,'vintage')
                            dates1 = strcat(int2str(years(ind1)), '0', int2str(months(ind1)), days(ind1,:));
                            dates2 = strcat(int2str(years(ind2)), int2str(months(ind2)), days(ind2,:));
                        else
                            dates1 = strcat(days(ind1,:), '.0', int2str(months(ind1)) ,'.',int2str(years(ind1)));
                            dates2 = strcat(days(ind2,:), '.',  int2str(months(ind2)) ,'.',int2str(years(ind2)));
                        end
                        
                        dates1 = cellstr(dates1);
                        dates2 = cellstr(dates2);

                        % Reorder the dates
                        cellOfDates       = cell(size(dates1,1) + size(dates2,1),1);
                        cellOfDates(ind1) = dates1;
                        cellOfDates(ind2) = dates2;

                        % Strip empty cells (because som of the indXs are empty)
                        if nargout == 1
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                        elseif nargout == 2
                            varargout{1} = cellOfDates(~cellfun(@isempty,cellOfDates));
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = cellOfDates;     
                        else
                            error([mfilename ':: To many output arguments'])
                        end

                    case {'nbnorsk','nbnorwegian'}

                        % Get the dates
                        months = int2str(months);
                        months = strtrim(cellstr(months));
                        months = strrep(months,'10','okt. ');
                        months = strrep(months,'11','nov. ');
                        months = strrep(months,'12','des. ');
                        months = strrep(months,'1','jan. ');
                        months = strrep(months,'2','feb. ');
                        months = strrep(months,'3','mar. ');
                        months = strrep(months,'4','apr. ');
                        months = strrep(months,'5','mai. ');
                        months = strrep(months,'6','jun. ');
                        months = strrep(months,'7','jul. ');
                        months = strrep(months,'8','aug. ');
                        months = strrep(months,'9','sep. ');
                        months = char(months);

                        years  = int2str(years);
                        years  = years(:,3:4);

                        dates  = strcat(months,years);

                        % Give the outputs
                        if nargout == 1
                            varargout{1} = cellstr(dates);
                        elseif nargout == 2
                            varargout{1} = cellstr(dates);
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = dates;     
                        else
                            error([mfilename ':: To many output arguments'])
                        end

                    case {'nbengelsk','nbenglish'}

                        % Get the dates
                        months = int2str(months);
                        months = strtrim(cellstr(months));
                        months = strrep(months,'10','Oct-');
                        months = strrep(months,'11','Nov-');
                        months = strrep(months,'12','Dec-');
                        months = strrep(months,'1','Jan-');
                        months = strrep(months,'2','Feb-');
                        months = strrep(months,'3','Mar-');
                        months = strrep(months,'4','Apr-');
                        months = strrep(months,'5','May-');
                        months = strrep(months,'6','Jun-');
                        months = strrep(months,'7','Jul-');
                        months = strrep(months,'8','Aug-');
                        months = strrep(months,'9','Sep-');
                        months = char(months);

                        years  = int2str(years);
                        years  = years(:,3:4);

                        dates  = strcat(months,years);

                        % Give the outputs
                        if nargout == 1
                            varargout{1} = cellstr(dates);
                        elseif nargout == 2
                            varargout{1} = cellstr(dates);
                            varargout{2} = 1:periods(end) + 1;
                        elseif nargout == 0
                            varargout{1} = dates;
                        else
                            error([mfilename ':: To many output arguments'])
                        end
                        
                    otherwise
                        error([mfilename ':: Unsupported date format; ' format])
                end

            case {52,365}

                error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                                 'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

            otherwise

                error([mfilename ':: Unsupported frequency; ' int2str(newFreq)])

        end

    end

end
