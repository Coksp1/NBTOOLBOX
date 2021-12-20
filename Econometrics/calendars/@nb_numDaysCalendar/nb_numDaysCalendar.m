classdef nb_numDaysCalendar < nb_calendar
% Description:
%
% An object that will provide the a calendar with X days after the end of 
% each month, quarter, etc. E.g. if numDays is set to 10, and frequency is 
% set to 4,  you will get 10.01.2000, 10.04.2000,...
%
% Superclasses:
% nb_calendar
%
% Constructor:
%
%   obj = nb_numDaysCalendar(numDays,frequency)
% 
% Input:
%
% - numDays   : Number of days into the period. The frequency of the
%               period will decide what is allowed. Default is 1.
%
% - frequency : The frequency of the provided kalendar. 
%               > 1 : Yearly, i.e. each year back in time.
%               > 2 : Semi-annually, i.e. each half-year back in time. 
%               > 4 : Quarterly, i.e. each quarter back in time. 
%               > 12: Monthly, i.e. each month back in time. 
%               Default is yearly (1).
%
% See also: 
% nb_currentCalendar, nb_MPRCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
        
        % The frequency of the current calendar.
        frequency = 1;
    
        % Number of days into the period.
        numDays   = 1;
        
    end
    
    methods 
        
        function obj = nb_numDaysCalendar(numDays,frequency)
            if nargin < 1
                return
            end
            if ~ismember(frequency,[1,2,4,12])
                error([mfilename ':: The frequency input must be 1, 2, 4 or 12.'])
            end
            obj.frequency = frequency;
            if ~nb_isScalarInteger(numDays,0)
                error([mfilename ':: The numDays input must be a scalar integer greater than 0.'])
            end
            switch obj.frequency
                case 1
                    if numDays > 365
                        error([mfilename ':: A year has no more than 365 days.'])
                    end
                case 2
                    if numDays > 181
                        error([mfilename ':: For semi-annually frequency 181 days is max.'])
                    end
                case 4
                    if numDays > 90
                        error([mfilename ':: For quarterly frequency 90 days is max.'])
                    end
                case 12
                    if numDays > 28
                        error([mfilename ':: For monthly frequency 28 days is max.'])
                    end
                    
            end
            obj.numDays = numDays;
            
        end
        
        function s = struct(obj)
           s = struct('class',class(obj),...
                      'numDays',obj.numDays,...
                      'frequency',obj.frequency); 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(s)
            obj = nb_numDaysCalendar(s.numDays,s.frequency);
        end
        
    end

end
