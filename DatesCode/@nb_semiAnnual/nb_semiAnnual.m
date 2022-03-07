classdef nb_semiAnnual < nb_date
% Description:
%
% A class representing a semiannual date.
%
% Superclasses:
%
% nb_date
% 
% Constructor:
%
%   obj = nb_semiAnnual(halfYear,year)
% 
%   Input:
%
%   - halfYear : A string on one of the following date formats:
% 
%                > 'yyyySq'
% 
%                > 'dd.mm.yyyy' 
% 
%                Or an intger with the half year. (Must be combined 
%                with the year argument)
% 
%   - year     : Must be an integer with the year. 
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
% nb_date, nb_year, nb_quarter, nb_month, nb_day, nb_week
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The frequency of the date. Must be 1.
        frequency  = 2;
        
        % The given half year as a double.
        halfYear   = [];
        
        % The number of half years since the base. 
        % Which is the first half year of 2000
        halfYearNr = [];
        
        % The given year as a double
        year       = [];
        
    end
    
    methods
        
        function obj = nb_semiAnnual(halfYear,year)
           
            if nargin == 1
                
                halfYear = strtrim(halfYear);
                exp      = regexp(halfYear,'[0-9]{1,4}[SH][1-2]{1,1}','match');
                if ~isempty(exp)

                    ind            = size(halfYear,2);
                    obj.year       = str2double(halfYear(1:ind-2));
                    yearObj        = nb_year(obj.year);
                    obj.halfYear   = str2double(halfYear(ind));
                    obj.halfYearNr = obj.halfYear + 2*yearObj.yearNr - 1;
                    obj.leapYear   = yearObj.leapYear;

                else

                    exp = regexp(strtrim(halfYear),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                    if ~isempty(exp)

                        obj.year = str2double(halfYear(7:10));
                        yearObj  = nb_year(obj.year);

                        month = str2double(halfYear(4:5));
                        switch month

                            case {1,2,3,4,5,6}

                                obj.halfYear = 1;

                            case {7,8,9,10,11,12}

                                obj.halfYear = 2;

                            otherwise

                                error([mfilename ':: Unsupported date format; ' halfYear '. Must either be ''yyyyQq)'' or ''dd.mm.yyyy''.'])

                        end

                        obj.halfYearNr = obj.halfYear + 2*yearObj.yearNr - 1;
                        obj.leapYear  = yearObj.leapYear;

                    else

                        error([mfilename ':: Unsupported date format; ' halfYear '. Must either be ''yyyyQq'' or ''dd.mm.yyyy''.'])

                    end
                 
            
                end
                
            elseif nargin == 2
           
                yearObj        = nb_year(year);
                obj.halfYear   = halfYear;
                obj.halfYearNr = obj.halfYear + 2*yearObj.yearNr - 1;
                obj.year       = yearObj.year;
                obj.leapYear   = yearObj.leapYear;

            end
            
            if obj.halfYear > 2 
                error([mfilename ':: A year consist of only 2 half years, doesn''t it?'])
            end
            
        end
        
    end
    
    %{
    =======================================================================
    Protected methods
    =======================================================================
    %}
    methods (Access=protected)
        

    end
    
    %{
    =======================================================================
    Static methods
    =======================================================================
    %}
    methods (Static=true)
        
        varargout = today(varargin)
        
    end
    
end
