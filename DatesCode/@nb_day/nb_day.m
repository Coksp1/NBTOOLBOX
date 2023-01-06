classdef nb_day < nb_date
% Description:
%
% A class representing a daily date. 
%
% Superclasses:
%
% nb_date
% 
% Constructor:      
%
%   obj = nb_day(day)
%   obj = nb_day(day,month,year)
% 
%   Input:
% 
%   - day   : A string on one of the following date formats:
% 
%             > 'yyyyMm(m)Dd(d)', e.g. '2012M1D10'
%
%             > 'dd.mm.yyyy', e.g. '10.01.2012'
% 
%             > 'ddmonyyyy', e.g. '10jan2012' 
%
%             > 'yyyymmdd', e.g. '20121231'
% 
%             Or an intger with the day. (Must be combined 
%             with the month and year arguments)
%         
%   - month : Must be an integer with the month.
%
%   - year  : Must be an intger with the year.
% 
%   Output:
% 
%   - obj   : An nb_day object.
% 
%   Examples:
% 
%   obj = nb_day('2012M1D10');
%   obj = nb_day(1,1,2012);
% 
% See also: 
% nb_date, nb_year, nb_semiAnnual, nb_quarter, nb_month
% 
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The given day as a double
        day       = [];
        
        % The number of days since the base year, which is 
        % 1.1.2000
        dayNr     = [];
        
        % The frequency of the date. Must be 365.
        frequency = 365;
        
        % The month of the given day
        month     = [];
        
        % The quarter of the given day
        quarter   = [];
        
        % The year of the given day
        year      = [];
        
    end
    
    methods

        function obj = nb_day(day,month,year)
            
            if nargin == 1
                
                day = strtrim(day);
                day = upper(day);
                exp = regexp(day,'[0-9]{1,4}M[0-9]{1,2}D[0-9]{1,2}','match');
                if ~isempty(exp)

                    ind  = strfind(day,'D');
                    indM = strfind(day,'M');

                    obj.day           = str2double(day(ind + 1:end));
                    yearObj           = nb_year(str2double(day(1:indM - 1)));
                    obj.year          = yearObj.year;
                    obj.leapYear      = yearObj.leapYear;
                    obj.month         = str2double(day(indM + 1:ind - 1));
                    obj.quarter       = findQuarter(obj);
                    numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj); 
                    obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;

                else

                    exp = regexp(strtrim(day),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                    if ~isempty(exp)

                        obj.day           = str2double(day(1:2));
                        yearObj           = nb_year(str2double(day(7:10)));
                        obj.year          = yearObj.year;
                        obj.leapYear      = yearObj.leapYear;
                        obj.month         = str2double(day(4:5));
                        obj.quarter       = findQuarter(obj);
                        numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj);
                        obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;

                    else

                        exp = regexp(strtrim(day),'[0-9]{1,2}\D{3,3}[0-9]{4,4}','match');
                        if ~isempty(exp)

                            if length(day) == 8
                                obj.day           = str2double(day(1));
                                yearObj           = nb_year(str2double(day(5:8)));
                                obj.year          = yearObj.year;
                                obj.leapYear      = yearObj.leapYear;
                                monthTemp         = day(2:4);
                            else
                                obj.day           = str2double(day(1:2));
                                yearObj           = nb_year(str2double(day(6:9)));
                                obj.year          = yearObj.year;
                                obj.leapYear      = yearObj.leapYear;
                                monthTemp         = day(3:5);
                            end
                            
                            switch lower(monthTemp)
                                
                                case 'jan'
                                    obj.month = 1;
                                case 'feb'
                                    obj.month = 2;
                                case 'mar'
                                    obj.month = 3;
                                case 'apr'
                                    obj.month = 4;
                                case 'may'
                                    obj.month = 5;
                                case 'jun'
                                    obj.month = 6;
                                case 'jul'
                                    obj.month = 7;
                                case 'aug'
                                    obj.month = 8;
                                case 'sep'
                                    obj.month = 9;
                                case 'oct'
                                    obj.month = 10;
                                case 'nov'
                                    obj.month = 11;
                                case 'dec'
                                    obj.month = 12;
                                otherwise
                                    error([mfilename ':: Unsupported date format; ' day '. Must either be ''yyyyMm(m)Dd(d)'', ''ddmonyyyy'' or ''dd.mm.yyyy''.'])
                            end
                            obj.quarter       = findQuarter(obj);
                            numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj);
                            obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;

                        else

                            exp = regexp(strtrim(day),'[0-9]{8,8}','match');
                            if ~isempty(exp)

                                obj.day           = str2double(day(7:8));
                                yearObj           = nb_year(str2double(day(1:4)));
                                obj.year          = yearObj.year;
                                obj.leapYear      = yearObj.leapYear;
                                obj.month         = str2double(day(5:6));
                                obj.quarter       = findQuarter(obj);
                                numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj); 
                                obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;

                            else

                                exp = regexp(strtrim(day),'[0-9]{1,4}-[0-9]{2,2}-[0-9]{2,2}','match');
                                if ~isempty(exp)

                                    obj.day           = str2double(day(9:10));
                                    yearObj           = nb_year(str2double(day(1:4)));
                                    obj.year          = yearObj.year;
                                    obj.leapYear      = yearObj.leapYear;
                                    obj.month         = str2double(day(6:7));
                                    obj.quarter       = findQuarter(obj);
                                    numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj); 
                                    obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;

                                else

                                    error([mfilename ':: Unsupported date format; ' day '. Must either be ''yyyyMm(m)Dd(d)'', ''ddmonyyyy'',',...
                                        ' ''yyyy-mm-dd'', ''yyyymmdd'' or ''dd.mm.yyyy''.'])

                                end

                            end

                        end

                    end

                end
                
            elseif nargin == 3
                    
                obj.day           = day;
                obj.month         = month;
                obj.quarter       = findQuarter(obj);
                yearObj           = nb_year(year);
                obj.year          = yearObj.year;
                obj.leapYear      = yearObj.leapYear;
                numberOfLeapYears = nb_day.getNumberOfLeapYears(yearObj); 
                obj.dayNr         = obj.getNumberOfDaysUntilNowInYear() + 365*yearObj.yearNr + numberOfLeapYears;
                
            elseif nargin == 0
                
                return
                
            else
                
                error([mfilename ':: Too many arguments to the constructor of the nb_day class.'])
                
            end
            
            if obj.month > 12 
                error([mfilename ':: The year has not more than 12 months'])
            end
            
            if ischar(day)
                extra = day;
            else
                extra = '';
            end
            switch obj.month
                
                case {1,3,5,7,8,10,12}
                    
                    if obj.day > 31
                        error([mfilename ':: The month you have given has only 31 days. ' extra])
                    end
                    
                case 2
                    
                    if obj.leapYear
                        if obj.day > 29
                            error([mfilename ':: The month you have given has only 29 days. ' extra])
                        end
                    else
                        if obj.day > 28
                            error([mfilename ':: The month you have given has only 28 days. ' extra])
                        end
                    end
                    
                case {4,6,9,11}
                    
                    if obj.day > 30
                        error([mfilename ':: The month you have given has only 30 days. ' extra])
                    end
                    
                otherwise
                    
                    error([mfilename ':: A year consist of only 12 month, doesn''t it? ' extra])
                    
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
        
    end

    %{
    =======================================================================
    Static methods
    =======================================================================
    %}
    methods (Static=true)

        varargout = getNumberOfDaysInMonth(varargin)
        
        varargout = today(varargin)
        
    end
    
    methods(Static=true,Access=protected,Hidden=true)
        
        function numLeapYears = getNumberOfLeapYears(yearObj)
        
            numLeapYears = floor(abs(yearObj.yearNr)/4) - floor(abs(yearObj.yearNr)/100) + floor(abs(yearObj.yearNr)/400);
            
            % If we current object is in a leap year we must 
            % correct for the fact that we haven't reach the
            % 29 of febuary for positive yearNr.
            if ~yearObj.leapYear && yearObj.yearNr > 0
                numLeapYears = numLeapYears + 1; 
            elseif yearObj.leapYear && yearObj.yearNr > 0
                %numLeapYears = numLeapYears - 1;
            elseif yearObj.yearNr < 0
                numLeapYears = -numLeapYears;
            end
            
        end

    end
    
end
