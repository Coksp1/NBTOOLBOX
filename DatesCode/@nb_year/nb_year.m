classdef nb_year < nb_date 
% Description:
%
% A class representing a yearly date. 
% 
% Superclasses:
%
% nb_date
%
% Constructor:
%
%   obj = nb_year(year)
% 
%   Input:
% 
%   - year : Either a string or an integer representing the 
%            year. I.e. 'yyyy', 'yyyyY01', 'yyyyY1' or yyyy.
% 
%   Output:
% 
%   - obj  : An nb_year object.
% 
%   Examples:
% 
%   obj = nb_year('2012');
%   obj = nb_year(2012);
% 
% See also: 
% nb_date, nb_semiAnnual, nb_quarter, nb_month, nb_day 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The frequency of the date. Must be 1.
        frequency = 1;  
        
        % The given year as a double
        year      = []; 
        
        % The number of years since the base year. Which is 
        % 2000
        yearNr    = [];
        
    end
    
    methods 
        
        function obj = nb_year(year)
            
            if nargin == 1
              
                if ischar(year)

                    if length(year) <= 4
                        yearStr = year;
                        try
                            year = str2double(year);
                        catch  %#ok<CTCH>
                            error([mfilename ':: Unsupported date format; ' yearStr '. Must either be ''yyyy'' or ''dd.mm.yyyy''.'])
                        end
                        
                        if isnan(year)
                            error([mfilename ':: Unsupported date format; ' yearStr '. Must either be ''yyyy'' or ''dd.mm.yyyy''.'])
                        end
                        
                    else
                        exp = regexp(strtrim(year),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                        if ~isempty(exp)
                            year = str2double(year(7:10));
                        else
                            exp = regexp(strtrim(year),'[0-9]{1,4}Y[0-9]{0,2}','match');
                            if ~isempty(exp)
                                year = str2double(year(1:4));
                            else
                                error([mfilename ':: Unsupported date format; ' year '. Must either be ''yyyy'', ''yyyyY'' or ''dd.mm.yyyy''.'])
                            end
                        end
                    end

                elseif isnumeric(year)

                    if ceil(year) ~= year
                        error([mfilename ':: If the input ''year'' is given as a number it must be an integer.'])
                    end

                end

                obj.year   = year;
                obj.yearNr = year - obj.baseYear;
                
                % Check if the given year is a leap year
                obj = checkForLeapYear(obj);

            end
                
        end      
        
    end 
    
    methods (Static=true)
        
        varargout = today(varargin)
        
        function leapYear = isLeapYear(year)
            
            % Check if the given year is a leap year           
            if year/4 - floor(year/4) == 0

                if year/400 - floor(year/400) == 0
                    leapYear = 1;
                else
                    if year/100 - floor(year/100) == 0
                        leapYear = 0;
                    else
                        leapYear = 1;
                    end
                end

            else
                leapYear = 0;
            end
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function obj = checkForLeapYear(obj)
            
            obj.leapYear = nb_year.isLeapYear(obj.year);
            
        end
        
        
    end
     
end
