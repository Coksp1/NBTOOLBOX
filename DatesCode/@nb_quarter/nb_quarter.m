classdef nb_quarter < nb_date
% Description:
%
% A class representing a quarterly date. 
%
% Superclasses:
%
% nb_date
%
% Constructor:      
%
%   obj = nb_quarter(quarter,year)
% 
%   Input:
%         
%   - quarter : A string on one of the following date formats:
% 
%               > 'yyyyQq'
% 
%               > 'dd.mm.yyyy' 
% 
%               Or an intger with the quarter. (Must be combined 
%               with the year argument) 
% 
%   - year    : Must be an integer with the year.
% 
%   Output:
% 
%   - obj     : An nb_quarter object
% 
%   Examples:
% 
%   obj = nb_quarter('2012Q1');
%   obj = nb_quarter(1,2012);
% 
% See also: 
% nb_date, nb_year, nb_semiAnnual, nb_month, nb_day 
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The frequency of the date. Must be 4.
        frequency = 4;
        
        % The given quarter as a double
        quarter   = [];
        
        % The number of quarters since the base, which 
        % is first quarter of 2000.
        quarterNr = [];
        
        % The year of the given quarter
        year      = [];
        
    end
    
    methods
        
        function obj = nb_quarter(quarter,year)
           
            if nargin == 1
                
                quarter = strtrim(quarter);
                exp     = regexp(quarter,'[0-9]{1,4}[QK][1-4]{1,1}','match');
                if ~isempty(exp)

                    ind           = size(quarter,2);
                    obj.year      = str2double(quarter(1:ind-2));
                    yearObj       = nb_year(obj.year);
                    obj.quarter   = str2double(quarter(ind));
                    obj.quarterNr = obj.quarter + 4*yearObj.yearNr - 1;
                    obj.leapYear  = yearObj.leapYear;

                else

                    exp = regexp(strtrim(quarter),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
                    if ~isempty(exp)

                        obj.year = str2double(quarter(7:10));
                        yearObj  = nb_year(obj.year);

                        month = str2double(quarter(4:5));
                        switch month

                            case {1,2,3}

                                obj.quarter = 1;

                            case {4,5,6}

                                obj.quarter = 2;

                            case {7,8,9}

                                obj.quarter = 3;

                            case {10,11,12}

                                obj.quarter = 4;

                            otherwise

                                error([mfilename ':: Unsupported date format; ' quarter '. Must either be ''yyyyQq)'' or ''dd.mm.yyyy''.'])

                        end

                        obj.quarterNr = obj.quarter + 4*yearObj.yearNr - 1;
                        obj.leapYear  = yearObj.leapYear;

                    else

                        error([mfilename ':: Unsupported date format; ' quarter '. Must either be ''yyyyQq'' or ''dd.mm.yyyy''.'])

                    end
                 
            
                end
                
            elseif nargin == 2
           
                yearObj       = nb_year(year);
                obj.quarter   = quarter;
                obj.quarterNr = obj.quarter + 4*yearObj.yearNr - 1;
                obj.year      = yearObj.year;
                obj.leapYear  = yearObj.leapYear;

            end
            
            if obj.quarter > 4 
                error([mfilename ':: A year consist of only 4 quarters, doesn''t it?'])
            end
            
        end
        
    end
    
    methods(Static=true)
        
        varargout = today(varargin)
        
    end
end
    
