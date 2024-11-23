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
% - obj     : An object of class nb_quarter
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : Set the format of the cellstr of dates:
%
%             > 'nb_date' : The output will be a vector of nb_date objects.
% 
%             > 'default' : 'yyyyQq'
% 
%             > 'fame'    : 'yyyyQq'
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
%                 > 12  : Not possible
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
%                 > 2   : 'mmm-yy', e.g. 'Jan-08' and 'Jul-08' 
%                 > 4   : 'yyyyQq' 
%                 > 12  : Not possible
%                 > 52  : Not possible
%                 > 365 : Not possible
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
% - newFreq  : > 1   : yearly
%              > 2   : semiannually
%              > 4   : quarterly
%              > 12  : monthly (Not possible)
%              > 52  : weekly  (Not possible)
%              > 365 : daily   (Not possible)
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 4;
            if nargin < 3
                format = 'default';

            end
        end
    end
    if ~(newFreq == 4) && strcmp(format,'nb_quarter')
        error('Wrong frequency. Must be 4')
        
    end
    
    if isempty(periods)
        error([mfilename ':: The input ''periods'' is empty, but it must be double (vector). E.g. -10:10.'])
    elseif ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    end    

    periods           = periods(:);
    SampleStartPeriod = obj.quarter;
    SampleStartYear   = obj.year;

    years    = floor((periods + SampleStartPeriod - 1)/4 + SampleStartYear);
    quarters = SampleStartPeriod + periods - (years - SampleStartYear)*4;

    switch newFreq

        case 1

            % Find the dates
            firstYear = obj.getYear();
            lastDate  = obj + periods(end);
            lastYear  = lastDate.getYear();
            periods   = lastYear - firstYear;

            if first
                quarter1      = firstYear.getQuarter(first);
                if obj ~= quarter1
                    dates = firstYear.toDates(1:periods,format);
                    firstYear = firstYear + 1;
                else
                    dates = firstYear.toDates(0:periods,format);
                end
            else
                dates = firstYear.toDates(0:periods,format);
            end

            if first == 0
                testDate = lastYear.getQuarter(first).toString();
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
                    endDays{ii} = yearT.getQuarter(first).toString();

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

        case 2

            % Find the dates
            firstHalfYear = obj.getHalfYear();
            lastDate      = obj + periods(end);
            lastHalfYear  = lastDate.getHalfYear();
            periods       = lastHalfYear - firstHalfYear;

            if first
                quarter1      = firstHalfYear.getQuarter(first);
                if obj ~= quarter1
                    dates = firstHalfYear.toDates(1:periods,format);
                    firstHalfYear = firstHalfYear + 1;
                else
                    dates = firstHalfYear.toDates(0:periods,format);
                end
            else
                dates = firstHalfYear.toDates(0:periods,format);
            end

            if first == 0
                testDate = lastHalfYear.getQuarter(first).toString();
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
                    endDays{ii}  = halfYearT.getQuarter(first).toString();

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

            switch lower(format)
                case 'nb_date'
                    
                    dates(length(periods),1) = nb_quarter();
                    for ii = 1:length(periods)
                        dates(ii)           = nb_quarter(quarters(ii),years(ii));
                        dates(ii).dayOfWeek = obj.dayOfWeek;
                    end
                    
                case {'default','nbengelsk','nbenglish','fame'}
                    
                    freqSign    = 'Q';
                    dates       = strcat(int2str(years),freqSign,int2str(quarters));
                    cellOfDates = cellstr(dates);
                    
                case {'xls','vintage'}
                    
                    nrPeriods = length(periods);
                    
                    if first == 1
                        months = quarters*3 - 2;
                        days   = strcat(int2str(zeros(nrPeriods,1)),int2str(ones(nrPeriods,1)));
                    else
                        months = quarters*3;
                        switch months(1)
                            case 3
                                start = [31;30;30;31];
                            case 6
                                start = [30;30;31;31];
                            case 9
                                start = [30;31;31;30];
                            case 12
                                start = [31;31;30;30];
                        end
                        
                        nrYears = years(end) - years(1) + 1;
                        days    = repmat(start,nrYears,1);
                        days    = days(1:nrPeriods);
                        days    = int2str(days);
                        
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
                    cellOfDates = cellOfDates(~cellfun(@isempty,cellOfDates));
                    
                case {'nbnorsk','nbnorwegian'}
                    
                    freqSign    = '.kv.';
                    years       = int2str(years);
                    dates       = strcat(int2str(quarters),freqSign,years(:,3:4));
                    cellOfDates = cellstr(dates);
                    
                otherwise
                    
                    error([mfilename ':: Unsupported date format; ' format])
                    
            end

            % Give the outputs
            if strcmp(format,'nb_date')
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
                    varargout{1} = cellOfDates;
                elseif nargout == 2
                    varargout{1} = cellOfDates;
                    varargout{2} = 1:periods(end) + 1;
                elseif nargout == 0
                    varargout{1} = cellOfDates;
                else
                    error([mfilename ':: To many output arguments'])
                end
            end

        case {12,52,365}

            error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                             'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

        otherwise

            error([mfilename ':: Unsupported frequency; ' int2str(newFreq)])

    end

end
