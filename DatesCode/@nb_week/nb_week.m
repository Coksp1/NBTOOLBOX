classdef nb_week < nb_date
% Description:
%
% A class representing a weekly date. 
%
% Superclasses:
%
% nb_date
% 
% Constructor:      
%
%   obj = nb_week(week)
%   obj = nb_week(week,dayOfWeek)
%   obj = nb_week(week,year)
%   obj = nb_week(week,year,dayOfWeek)
%
%   Input:
% 
%   - week      : A string on one of the following date formats:
% 
%                 > 'yyyyWw(w)', e.g. '2012W1'
%
%                 > 'dd.mm.yyyy', e.g. '10.01.2012', '17.01.2012'
% 
%                 Or an intger with the week. (Must be combined 
%                 with the year arguments)
%         
%   - year      : Must be an integer with the year.
%
%   - dayOfWeek : Should only be provided with the date format 'yyyyWw(w)'
%                 or when week and year inputs are both doubles. Default
%                 is 1, which is sunday.
% 
%   Output:
% 
%   - obj   : An nb_week object.
% 
%   Examples:
% 
%   obj = nb_week('01.01.2001'); 
%   obj = nb_week('2001W1');
%   obj = nb_week('2001W1',1);
%   obj = nb_week(1,2001);
%   obj = nb_week(1,2001,1);
% 
% See also: 
% nb_date, nb_year, nb_semiAnnual, nb_quarter, nb_month, nb_day
% 
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The given day as a double
        week        = [];
        
        % The number of weeks since the base year, which is 
        % the first week of 2000
        weekNr      = [];
        
        % The frequency of the date. Must be 52.
        frequency   = 52;
        
        % Indicator. Is 1 if the year has 53 weeks, otherwise 0.
        specialYear = 0;
        
        % The year of the given week
        year        = [];
        
    end
    
    methods

        function obj = nb_week(week,year,dayOfWeek)
        % Constructor
        
            if nargin == 0
                return
            elseif nargin > 3
                error([mfilename ':: Too many arguments to the constructor of the nb_week class.'])
            end
                
            if nargin == 1
                
                exp = regexp(strtrim(week),'[0-9]{1,4}W[0-9]{1,2}','match');
                if ~isempty(exp)

                    ind      = strfind(week,'W');
                    obj.week = str2double(week(ind + 1:end));
                    yearTemp = str2double(week(1:4));

                else

                    exp = regexp(strtrim(week),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                    if ~isempty(exp)

                        yearTemp     = str2double(week(7:10));
                        yearObj      = nb_year(yearTemp);
                        obj.year     = yearObj.year;
                        obj.leapYear = yearObj.leapYear;
                        
                        % Get the week as a number, weekday and 
                        % the year (e.g. '2002W1' for the date
                        % '31.12.2001')
                        [weekNum,weekDay,yearTemp] = nb_week.getWeekNumber(week,obj.leapYear,true);
                        obj.week      = weekNum;
                        obj.dayOfWeek = weekDay;

                    else
                        % Test if the date is on the 'ddmonYYYY' format, e.g. '10jan2012' 
                        exp = regexp(strtrim(week),'[0-9]{1,2}\D{3,3}[0-9]{1,4}','match');
                        if ~isempty(exp)

                            yearTemp     = str2double(week(6:end));
                            yearObj      = nb_year(yearTemp);
                            obj.year     = yearObj.year;
                            obj.leapYear = yearObj.leapYear;

                            % Get the week as a number, weekday and 
                            % the year (e.g. '2002W1' for the date
                            % '31dec2001')
                            [weekNum,weekDay,yearTemp] = nb_week.getWeekNumber(week,obj.leapYear,false);
                            obj.week      = weekNum;
                            obj.dayOfWeek = weekDay;

                        else
                            error([mfilename ':: Unsupported date format; ' week '. Must either be ''yyyyWw(w)'' or ''dd.mm.yyyy''.'])
                        end
                    end

                end
                
            elseif nargin == 2
                
                if ischar(week)
                    
                    exp = regexp(strtrim(week),'[0-9]{1,4}W[0-9]{1,2}','match');
                    if ~isempty(exp)

                        ind      = strfind(week,'W');
                        obj.week = str2double(week(ind + 1:end));
                        yearTemp = str2double(week(1:4));

                    else
                        error([mfilename ':: Unsupported date format; ' week '. Must either be ''yyyyWw(w)'' (when 2 inputs are given).'])
                    end
                    
                    % The year input is now the day the week 
                    % represents when converted to daily frequency
                    if isnumeric(year) && year > 0 && year < 8
                        obj.dayOfWeek = year;
                    else
                        error([mfilename ':: When the first input is a string on the format ''yyyyWw(w)'' '...
                            'then the second input must be a number indicating the weekday. (1-7 (monday-sunday))'])
                    end
                    
                else
                    obj.week = week;
                    yearTemp = year;
                end
                
            elseif nargin == 3
                
                obj.week = week;
                yearTemp = year;
                
                % The year input is now the day the week 
                % represents when converted to daily frequency
                if isnumeric(dayOfWeek) && dayOfWeek > 0 && dayOfWeek < 8
                    obj.dayOfWeek = dayOfWeek;
                else
                    error([mfilename ':: The dayOfWeek must be given as a number (1-7 (monday-sunday))'])
                end
                
            end
            
            yearObj         = nb_year(yearTemp);
            obj.year        = yearObj.year;
            obj.leapYear    = yearObj.leapYear;
            obj.weekNr      = obj.week + 52*yearObj.yearNr + getNumberOfSpecialYears(obj);
            obj.specialYear = nb_week.hasLeapWeek(obj.year); 
            if obj.week < 1
                error([mfilename ':: The week input must be an positiv integer'])
            end

            % Check the week input
            if obj.specialYear
                if obj.week > 53
                    error([mfilename ':: The year ' int2str(obj.year) ' has not more than 53 weeks'])
                end
            else
                if obj.week > 52 
                    error([mfilename ':: The year ' int2str(obj.year) ' has not more than 52 weeks'])
                end
            end
                    
        end
        
    end
    
    
    methods (Access=protected)
        
        function quarter = findQuarter(obj)       
        % Find the quarter given the month
        %         
        % Input:
        %         
        % - obj       : an object
        %         
        % Output:
        %         
        % - quarter   : the quarter as an integer
        %             
        % Examples:
        %         
        % Written by Kenneth S. Paulsen
        
            switch obj.month
                case {1,2,3}
                    quarter = 1;
                case {4,5,6}
                    quarter = 2;
                case {7,8,9}
                    quarter = 3;
                otherwise
                    quarter = 4;
            end

        end
        
        function numberOfSpecialYears = getNumberOfSpecialYears(obj)
        % Get the number of years since the base year with 53 
        % weeks. When going back in time this number will be 
        % negativ.
            
            yearNr = obj.year - 2000;
            numberOfSpecialYears = floor(abs(yearNr)/400)*71;
            
            % Table with years with 53 weeks in a 400 years cycle
            table = [  4,   9,  15,  20,  26,  32,  37,  43,  48,...
                      54,  60,  65,  71,  76,  82,  88,  93,  99,...
                     105, 111, 116, 122, 128, 133, 139, 144,...
                     150, 156, 161, 167, 172, 178, 184, 189, 195,...
                     201, 207, 212, 218, 224, 229, 235, 240, 246,...
                     252, 257, 263, 268, 274, 280, 285, 291, 296,...
                     303, 308, 314, 320, 325, 331, 336, 342, 348,...
                     353, 359, 364, 370, 376, 381, 387, 392, 398];
            
            % Find the number of years with 53 weeks in the current
            % 400 years cycle
            yChecked = mod(abs(yearNr),400);
            if yearNr < 0
                ind = find(flip(table,2) >= 400 - yChecked,1,'last');
            else
                ind = find(table < yChecked,1,'last');
            end
            if isempty(ind)
                ind = 0;
            end
  
            numberOfSpecialYears = numberOfSpecialYears + ind;
            
            if yearNr < 0
                numberOfSpecialYears = -numberOfSpecialYears;
            end
            
        end
        
    end

    %{
    =======================================================================
    Static methods
    =======================================================================
    %}
    methods (Static=true)
        
        varargout = today(varargin)

        function [weekNum,weekDay,yearN] = getWeekNumber(date,leapYear,xls)
            
            if nargin < 3
                xls = true;
            end
            
            if xls
                day   = str2double(date(1:2));
                month = str2double(date(4:5));
                yearN = str2double(date(7:10));
            else
                day      = str2double(date(1:2));
                monthStr = date(3:5);
                switch lower(monthStr)
                    case 'jan'
                        month = 1;
                    case 'feb'
                        month = 2;
                    case 'mar'
                        month = 3;
                    case 'apr'
                        month = 4;
                    case 'may'
                        month = 5;
                    case 'jun'
                        month = 6;
                    case 'jul'
                        month = 7;
                    case 'aug'
                        month = 8;
                    case 'sep'
                        month = 9;
                    case 'oct'
                        month = 10;
                    case 'nov'
                        month = 11;
                    case 'dec'
                        month = 12;
                    otherwise
                        error([mfilename ':: Unsupported weekly date format ' date])
                end
                yearN = str2double(date(6:end));
            end
            ordD        = nb_week.getOrdinalDate(day,month,leapYear);
            date        = [int2str(month) '-' int2str(day) '-' int2str(yearN)];
            weekDay     = weekday(date);
            permutation = [1,2,3,4,5,6,7;7,1,2,3,4,5,6];
            ind         = weekDay == permutation(1,:);
            weekDayCalc = permutation(2,ind);
            weekNum     = floor((ordD - weekDayCalc + 10)/7);
            
            % When the formula above return 53 we must check if the
            % week should be the 53rd week of this year or the
            % the 1st of the next.
            
            if weekNum == 53
                weekDayEndOfYear = weekDay - 1 + 31 - day;
                if weekDayEndOfYear < 4
                    weekNum = 1;
                    yearN   = yearN + 1;
                end
            elseif weekNum == 0
                yearN = yearN - 1;
                if nb_week.hasLeapWeek(yearN)
                    weekNum = 53;
                else
                    weekNum = 52;
                end
                
            end
            
        end
        
        function dates = getXLSDate(weekNum,weekDay,years,first)
            
            if size(years,1) == 1
                years = repmat(years,size(weekNum,1),1);
            end
            
            permutation       = [1,2,3,4,5,6,7;7,1,2,3,4,5,6];
            ind               = weekDay == permutation(1,:);
            weekDayCalc       = permutation(2,ind);
            yearStr           = num2str(years);
            testDate          = strcat('01-Jan-',yearStr);
            testWeekDays      = weekday(testDate);
            testWeekDays      = testWeekDays - 2;
            ind               = testWeekDays == -1;
            testWeekDays(ind) = 6;
            testDate2         = strcat('01.01.',yearStr);
            correct           = ones(size(years,1),1);
            for ii = 1:size(years,1)  
                leapYear = nb_year.isLeapYear(years(ii));
                weekNumT = nb_week.getWeekNumber(testDate2(ii,:),leapYear,true);
                if any(weekNumT == [52,53])
                    correct(ii) = 0;
                end
            end
            ordinalDate = (weekNum - correct)*7 - testWeekDays + weekDayCalc;
            if first
                ordinalDate = ordinalDate - 6;
            end
            days   = ordinalDate;
            months = ordinalDate;
            
            % The negative values refere to a date from the 
            % previous year
            indNeg         = ordinalDate <= 0;
            days(indNeg)   = 31 + ordinalDate(indNeg);
            months(indNeg) = 12;
            years(indNeg)  = years(indNeg) - 1;
            
            % Get leap years
            leapY = false(size(years));
            ind1  = years/4 - floor(years/4) == 0;
            ind2  = years/400 - floor(years/400) == 0;
            ind3  = years/100 - floor(years/100) == 0;
            leapY(ind1 & ind2)  = true;
            leapY(ind1 & ~ind3) = true;
            
            % We must transfrom the ordinal dates to days and months
            daysPos   = ordinalDate(~indNeg);
            monthsPos = ordinalDate(~indNeg);
            yearsPos  = years(~indNeg);           
            numPos    = size(daysPos,1);
            
            if numPos > 0
                
                remove                 = repmat([0 31 59 90 120 151 181 212 243 273 304 334,365],numPos,1);
                leapYPos               = leapY(~indNeg);
                remove(leapYPos,3:end) = remove(leapYPos,3:end) + 1;
                ind                    = repmat(daysPos,1,13) > remove;

                % Remove the days not in the current month
                toRemove = zeros(numPos,1);
                for ii=1:numPos
                    for jj = 1:13
                        if ~ind(ii,jj)
                            toRemove(ii)  = remove(ii,jj-1);
                            monthsPos(ii) = jj - 1;
                            break
                        elseif jj == 13
                            toRemove(ii)  = remove(ii,jj);
                            monthsPos(ii) = 1;
                            yearsPos(ii)  = yearsPos(ii) + 1;
                        end
                    end
                end
                daysPos         = daysPos - toRemove;
                days(~indNeg)   = daysPos;
                months(~indNeg) = monthsPos;
                years(~indNeg)  = yearsPos;
                
            end
            
            % Concatenate to date strings
            days = num2str(days);
            if size(days,2) == 1
                days = strcat('0',days);
            end
            days   = strrep(cellstr(days),' ','0');
            
            months = num2str(months);
            if size(months,2) == 1
                months = strcat('0',months);
            end
            months = strrep(cellstr(months),' ','0'); 
            
            years  = cellstr(num2str(years)); 
            dates  = strcat(days,'.',months,'.',years);
            
        end
        
        function ret = hasLeapWeek(year)
            
            % Table with years with 53 weeks in a 400 years cycle
            table = [  4,   9,  15,  20,  26,  32,  37,  43,  48,...
                      54,  60,  65,  71,  76,  82,  88,  93,  99,...
                     105, 111, 116, 122, 128, 133, 139, 144,...
                     150, 156, 161, 167, 172, 178, 184, 189, 195,...
                     201, 207, 212, 218, 224, 229, 235, 240, 246,...
                     252, 257, 263, 268, 274, 280, 285, 291, 296,...
                     303, 308, 314, 320, 325, 331, 336, 342, 348,...
                     353, 359, 364, 370, 376, 381, 387, 392, 398];
            
            % Check if the year has a leap week 
            yChecked = mod(year,400);
            ret      = any(repmat(table,size(year,1),1) == repmat(yChecked,1,71),2);   
            
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        function ordDate = getOrdinalDate(day,month,leapYear)
        % Get ordinal date of a given day   
            
            months = 1:12;
            add    = [0 31 59 90 120 151 181 212 243 273 304 334];
            
            if leapYear
                add(3:end) = add(3:end) + 1;
            end
            
            ind     = month == months;
            ordDate = add(ind) + day;
            
        end
        
    end
    
    methods (Static=true,Access=protected,Hidden=true)
        
        function [week,year] = localplus(week,year,periods)

            if periods == 0
                return
            elseif periods > 0

                cont = true;
                week = week + periods;
                while cont

                    ret = nb_week.hasLeapWeek(year);
                    if ret 
                        maxWeeks = 53;
                    else
                        maxWeeks = 52;
                    end
                    if week > maxWeeks
                       week = week - maxWeeks;
                       year = year + 1; 
                    else
                        cont = false;
                    end

                end

            else

                cont = true;
                week = week + periods;
                while cont

                    if week < 1
                       year = year - 1;
                       ret  = nb_week.hasLeapWeek(year);
                       if ret 
                            maxWeeks = 53;
                        else
                            maxWeeks = 52;
                       end
                       week = week + maxWeeks; 
                    else 
                        cont = false;
                    end

                end

            end

        end
        
    end
    
end
