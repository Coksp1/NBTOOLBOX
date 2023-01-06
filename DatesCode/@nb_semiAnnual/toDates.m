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
% - obj     : The object itself
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : Set the format of the cellstr of dates:
% 
%             > 'nb_date' : The output will be a vector of nb_date objects.
%
%             > 'default' : 'yyyySs'
% 
%             > 'fame'    : 'yyyySs'
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
%                 > 4   : Not possible 
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
%                 > 4   : Not possible
%                 > 12  : Not possible
%                 > 52  : Not possible
%                 > 365 : Not possible
% 
%                 (Date strings are only given for the days which 
%                 ends the periods)
% 
% - newFreq  : > 1   : yearly
%              > 2   : semiannually
%              > 4   : quarterly (Not possible)
%              > 12  : monthly   (Not possible)
%              > 52  : weekly    (Not possible)
%              > 365 : daily     (Not possible)
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 2;
            if nargin < 3
                format = 'default';
            end
        end
    end
    if ~(newFreq == 2) && strcmp(format,'nb_semiAnnual')
        error('Wrong frequency. Must be 2')
        
    end

    if isempty(periods)
        error([mfilename ':: The input ''periods'' is empty, but it must be double (vector). E.g. -10:10.'])
    elseif ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    end    

    periods           = periods(:);
    SampleStartPeriod = obj.halfYear;
    SampleStartYear   = obj.year;

    years     = floor((periods + SampleStartPeriod - 1)/2 + SampleStartYear);
    halfyears = SampleStartPeriod + periods - (years - SampleStartYear)*2;

    switch newFreq

        case 1

            % Find the dates
            firstYear = obj.getYear();
            lastDate  = obj + periods(end);
            lastYear  = lastDate.getYear();
            periods   = lastYear - firstYear;

            if first
                halfYear1 = firstYear.getHalfYear(first);
                if obj ~= halfYear1
                    dates = firstYear.toDates(1:periods,format);
                    firstYear = firstYear + 1;
                else
                    dates = firstYear.toDates(0:periods,format);
                end
            else
                dates = firstYear.toDates(0:periods,format);
            end

            if first == 0
                testDate = lastYear.getHalfYear(first).toString();
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
                    endDays{ii} = yearT.getHalfYear(first).toString();

                end

                try
                    locations = nb_ts.locateVariables(endDays,datesDefault);
                catch  %#ok<CTCH>
                    try
                        locations = nb_ts.locateVariables(endDays(1:end-1),datesDefault);
                        dates     = dates(1:end-1);
                    catch %#ok<CTCH>
                        locations = nb_ts.locateVariables(endDays(2:end),datesDefault);
                        dates     = dates(2:end);
                    end
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

            switch lower(format)
                
                case 'nb_date'
                    
                    dates(length(periods),1) = nb_semiAnnual();
                    for ii = 1:length(periods)
                        dates(ii)           = nb_semiAnnual(halfyears(ii),years(ii));
                        dates(ii).dayOfWeek = obj.dayOfWeek;
                    end

                case {'default','fame'}

                    freqSign    = 'S';
                    dates       = strcat(int2str(years),freqSign,int2str(halfyears));
                    cellOfDates = cellstr(dates);

                case 'xls'

                    months = halfyears*6; 
                    if first == 1
                        start = [1;1];
                    else
                        switch months(1) 
                            case 6
                                start = [30;31];
                            case 12
                                start = [31;30];    
                        end
                    end

                    nrYears = years(end) - years(1) + 1;

                    days      = repmat(start,nrYears,1);
                    nrPeriods = length(periods);
                    days      = days(1:nrPeriods);

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

                    % Get the dates
                    months = int2str(halfyears);
                    months = cellstr(months);
                    months = strrep(months,'1','jan. ');
                    months = strrep(months,'2','jul. ');
                    months = char(months);

                    years  = int2str(years);
                    years  = years(:,3:4);

                    dates       = strcat(months,years);
                    cellOfDates = cellstr(dates);


                case {'nbengelsk','nbenglish'}

                    % Get the dates
                    months = int2str(halfyears);
                    months = cellstr(months);
                    months = strrep(months,'1','Jan-');
                    months = strrep(months,'2','Jul-');
                    months = char(months);

                    years  = int2str(years);
                    years  = years(:,3:4);

                    dates       = strcat(months,years);
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
                    varargout{2} = periods + 1;
                else
                    error([mfilename ':: To many output arguments'])
                end
                
             end
        case 4

            error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                             'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

        case 12

            error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                             'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

        case 52
            
            error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                             'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

                         
        case 365

            error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                             'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])

        otherwise

            error([mfilename ':: Unsupported frequency; ' int2str(newFreq)])

    end

end
