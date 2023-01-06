classdef nb_month < nb_date 
% Description:
%
% A class representing a monthly date. 
%
% Superclasses:
%
% nb_date
% 
% Constructor:
%
%   obj = nb_month(month,year)
% 
%   Input:
%
%   - month : A string on one of the following date formats:
% 
%             > 'yyyyMm(m)'
% 
%             > 'dd.mm.yyyy' 
% 
%             Or an intger with the month. (Must be combined 
%             with the year argument) 
% 
%   - year  : Must be an integer with the year.
% 
%   Output:
% 
%   - obj   : An nb_month object.
% 
%   Examples:
% 
%   obj = nb_month('2012M1');
%   obj = nb_month('01.01.2012');
%   obj = nb_month(1,2012);
% 
% See also: 
% nb_date, nb_year, nb_semiAnnual, nb_quarter, nb_day 
%
% Written by Kenneth Sæterhagen Paulsen
   
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The frequency of the date. Must be 12.
        frequency = 12;
        
        % The given month as a double
        month     = [];
        
        % The number of months since the base. 
        % Which is the first month of 2000.
        monthNr   = [];
        
        % The given quarter as a double.
        quarter   = [];
        
        % The given year as a double.
        year      = [];
          
    end
    
    methods 
        
        function obj = nb_month(month,year)
            
            if nargin == 1
                
                month = upper(month);
                month = strtrim(month);
                exp   = regexp(month,'[0-9]{1,4}M[0-9]{1,2}','match');
                if ~isempty(exp)

                    indM         = strfind(month,'M');
                    obj.year     = str2double(month(1:indM-1));
                    yearObj      = nb_year(obj.year);
                    obj.month    = str2double(month(indM+1:end));
                    obj.monthNr  = obj.month + 12*yearObj.yearNr - 1;
                    obj.quarter  = findQuarter(obj);
                    obj.leapYear = yearObj.leapYear;

                else

                    exp = regexp(strtrim(month),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                    if ~isempty(exp)

                        obj.year     = str2double(month(7:10));
                        yearObj      = nb_year(obj.year);
                        obj.month    = str2double(month(4:5));
                        obj.monthNr  = obj.month + 12*yearObj.yearNr - 1;
                        obj.quarter  = findQuarter(obj);
                        obj.leapYear = yearObj.leapYear;

                    else

                        error([mfilename ':: Unsupported date format; ' month '. Must either be ''yyyyMm(m)'' or ''dd.mm.yyyy''.'])

                    end

                end
                
            elseif nargin == 2
            
                obj.month    = month;
                yearObj      = nb_year(year);
                obj.year     = yearObj.year;
                obj.monthNr  = month + 12*yearObj.yearNr - 1;
                obj.quarter  = findQuarter(obj);
                obj.leapYear = yearObj.leapYear;
 
            end
            
            if obj.month > 12 
                error([mfilename ':: A year consist of only 12 month, doesn''t it?'])
            end
            
        end
        
    end
        
    %{
    ===============================================================
    Protected methods
    ===============================================================
    %}
    methods (Access=protected)
        
        function quarter = findQuarter(obj)
        % Find the quarter given the month 
        
            quarter = ceil(obj.month/3);
            
        end
        
        function days = days31(obj)
        % Construct the days objects of this month if it contains 
        % 31 days 
        
            days = cell(1,31);
            for ii = 1:31
                days{ii}           = nb_day(ii,obj.month,obj.year);
                days{ii}.dayOfWeek = obj.dayOfWeek;
            end
                       
        end
        
        function days = days30(obj)
        % Construct the days objects of this month if it contains 
        % 30 days 
        
            days = cell(1,30);
            for ii = 1:30
                days{ii}           = nb_day(ii,obj.month,obj.year);
                days{ii}.dayOfWeek = obj.dayOfWeek;
            end
                       
        end
        
        function days = daysFebruary(obj)
        % Construct the days objects of this month if it is 
        % february 
        
            switch obj.leapYear 
                
                case 1
                    
                    days = cell(1,29);
                    for ii = 1:29
                        days{ii}           = nb_day(ii,obj.month,obj.year);
                        days{ii}.dayOfWeek = obj.dayOfWeek;
                    end

                case 0
            
                    days = cell(1,28);
                    for ii = 1:28
                        days{ii}           = nb_day(ii,obj.month,obj.year);
                        days{ii}.dayOfWeek = obj.dayOfWeek;
                    end
                    
            end
                       
        end
        
    end
    
    %{
    ===============================================================
    Static methods
    ===============================================================
    %}
    methods (Static=true)
        
        varargout = today(varargin)
        
        function cellOfObjects = toCellOfObjects(months,years)
            
            cellOfObjects = cell(size(months));
            for ii = 1:size(months)
                cellOfObjects{ii} = nb_month(months(ii),years(ii));
            end
            
        end
        
    end
    
    
end
