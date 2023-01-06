function [startDate,frequency,type] = date2freq(dates,xls)
% Syntax:
%
% [startDate,frequency,type] = nb_date.date2freq(dates,xls)
% 
% Description:
% 
% A static method of the nb_date class.
%
% Find out the frequency of the data (also from a xls(x) worksheet)
% 
% When trying to figure out the frequency of excel dates, this
% function must have at least to following dates
% 
% yearly       : 'yyyy' or 'dd.mm.yyyy'
% semiannually : 'yyyySs' or 'dd.mm.yyyy'
% quarterly    : 'yyyyQq' or 'yyyyKk', 'dd.mm.yyyy'
% monthly      : 'yyyyMm(m)' or 'dd.mm.yyyy'
% weekly       : 'yyyyWw(w)' or 'dd.mm.yyyy'
% daily        : 'yyyyMm(m)Dd(d)', 'ddmonyyyy' or 'dd.mm.yyyy'
%
% Input:
% 
% - dates     : A cellstr of the dates you want to test the 
%               frequency of.
% 
% - xls       : > 'xls' : If you want to test if the dates is on 
%                         the format 'dd.mm.yyyy' also
%
%               > otherwise will not (default)
% 
% Output:
% 
% - startDate : An object which is a subclass of the class nb_date, 
%               with the start date of the input dates. (Either 
%               nb_quarter, nb_month, nb_semiAnnual, nb_year, 
%               nb_week or nb_day)
% 
% - frequency : The frequency of the dates given. 
% 
%               > 1   : yearly
%               > 2   : semiannually
%               > 4   : quarterly
%               > 12  : monthly 
%               > 52  : weekly
%               > 365 : daily
% 
% - type      : 1 if the dates input is on the xls format, 
%               otherwise 0
%                 
% Examples:
%
% dates = {'01.01.2012';'02.01.2012','03.01.2012'};
% [startDate,frequency,type] = nb_date.date2freq(dates,'xls');
% 
% The output will in this example be:
%
% - startDate : An nb_day object representing the date '01.01.2012'
%
% - frequency : 365
%
% - type      : 1
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        xls = 'notxls';
    end

    type = 0;

    if isempty(dates)
        startDate = [];
        frequency = [];
        type      = 0;
        return
    end
    
    if ischar(dates)
        if strcmpi(dates,'empty date object')
             startDate = [];
             frequency = [];
             type      = 0;
             return
        else
            dates = upper(cellstr(dates));
        end
    elseif isa(dates,'nb_date')
        startDate = dates;
        frequency = dates.frequency;
        type      = 0;
        return
    end
    dates = strtrim(dates);

    try
        if isnumeric(dates{1})
            
            if rem(dates{1},round(dates{1})) ~= 0 && ~isequal(dates{1},0)
                error([mfilename ':: The input to this function must eihter be a cell array of string of the dates or string (char) with a given date.'...
                             ' I.e. {''2012Q2'';''2012Q3'';...} or ''2012Q2''.'])
            else
                startDate = dates{1};
                frequency = 1;
                type      = 0;
                return
            end
            
        elseif ~ischar(dates{1})

            error([mfilename ':: The input to this function must eihter be a cell array of string of the dates or string (char) with a given date.'...
                             ' I.e. {''2012Q2'';''2012Q3'';...} or ''2012Q2''.'])

        end
    catch 
        error([mfilename ':: The input to this function must eihter be a cell array of string of the dates or string (char) with a given date.'...
                             ' I.e. {''2012Q2'';''2012Q3'';...} or ''2012Q2''.'])
    end

    frequency = [];

    % Test if the date is on the 'yyyyQq' format
    exp = regexp(strtrim(dates{1}),'[0-9]{1,4}[QK][1-4]','match');
    if ~isempty(exp)
        frequency = 4;
    else
        % Test if the date is on the 'yyyyMm(m)' format
        exp = regexp(strtrim(dates{1}),'[0-9]{1,4}M[0-9]{1,2}(?!.+)','match');
        if ~isempty(exp)
            frequency = 12;
        else
            % Test if the date is on the 'yyyy' format or if it is
            % a integer (as a string)
            exp = regexp(strtrim(dates{1}),'^-{0,1}([0-9]+)(?!.+)','match');
            if ~isempty(exp)

                if size(exp{1},2) == size(dates{1},2)
                    if size(exp{1},2) == 8
                        frequency = 365;
                    else
                        frequency = 1;
                    end
                else
                    error([mfilename ':: The given date format is not supported by this function (''' dates{1} ''')'])
                end

            else

                % Test if the date is on the 'yyyyMm(m)Dd(d)' format 
                exp = regexp(strtrim(dates{1}),'[0-9]{1,4}M[0-9]{1,2}D[0-9]{1,2}','match');
                if ~isempty(exp)
                    frequency = 365;
                else
                    % Test if the date is on the 'ddmonYYYY' format, e.g. '10jan2012' 
                    exp = regexp(strtrim(dates{1}),'[0-9]{1,2}\D{3,3}[0-9]{1,4}','match');
                    if ~isempty(exp)
                        if length(dates) < 3
                            % No way to separate between daily and weekly
                            frequency = 365;
                        else
                            day1  = regexp(strtrim(dates{1}),'^[0-9]{1,2}','match');
                            day1  = str2double(day1);
                            day2  = regexp(strtrim(dates{2}),'^[0-9]{1,2}','match');
                            day2  = str2double(day2);
                            day3  = regexp(strtrim(dates{3}),'^[0-9]{1,2}','match');
                            day3  = str2double(day3);
                            diff1 = abs(day2 - day1);
                            diff2 = abs(day3 - day2);
                            diff  = min(diff1,diff2);
                            if diff < 6
                                frequency = 365;
                            else
                                frequency = 52;
                            end
                        end
                    else
                        % Test if the date is on the 'yyyySs' format 
                        exp = regexp(strtrim(dates{1}),'[0-9]{1,4}[SH][1-2]{1,1}','match');
                        if ~isempty(exp)
                            frequency = 2;
                        else
                            % Test if the date is on the 'yyyyWw(w)' or 'yyyyUu(u)' format 
                            exp = regexp(strtrim(dates{1}),'[0-9]{1,4}[WU][0-9]{1,2}','match');
                            if ~isempty(exp)
                                frequency = 52;
                            else
                                % Test if the date is on the 'yyyyYy(y)' format 
                                exp = regexp(strtrim(dates{1}),'[0-9]{1,4}[Y][0-9]{1,2}','match');
                                if ~isempty(exp)
                                    frequency = 1;
                                else
                                    % Test if the date is on the 'yyyy-mm-dd' format 
                                    exp = regexp(strtrim(dates{1}),'[0-9]{1,4}-[0-9]{2,2}-[0-9]{2,2}','match');
                                    if ~isempty(exp)
                                        frequency = 365;
                                    end
                                    
                                end
                                
                            end
                            
                        end

                    end
                    
                end

            end

        end

    end
    
    % Test if the date is on a excel date format. See
    % the fromxlsDates2freq method
    switch xls

        case 'xls'

            if isempty(frequency)

                if size(dates,1) < 2 &&  size(dates,2) < 2
                   error([mfilename ':: Could not figure out the date format of the excel worksheet due to too few dates. (''' dates{1} ''') '...
                                    'Must at least have two dates. Use one of these formats instead; ''yyyyM(m)Dd(d)'', ''yyyyQq'', ''yyyyMmm'' or ''yyyy'''])
                elseif size(dates,1) < 2
                    dates = dates'; 
                end

                try
                    frequency = nb_date.fromxlsDates2freq(dates);
                    type      = 1;
                catch Err
                    error([mfilename ':: The given date format is not supported by this function (''' dates{1} ''') :: Error message :: ' Err.message])
                end

            end

        otherwise

            if isempty(frequency)
                error([mfilename ':: The given date format is not supported by this function (''' dates{1} ''')']) 
            end
    end

    % Transform the start date to a date object.
    startDate = dates{1};
    switch frequency
        case 365
            startDate = nb_day(startDate);
        case 52           
            startDate = nb_week(startDate);
        case 12
            startDate = nb_month(startDate);
        case 2
            startDate = nb_semiAnnual(startDate);
        case 1
            startDate = nb_year(startDate);
        case 4
            startDate = nb_quarter(startDate);
    end

end
