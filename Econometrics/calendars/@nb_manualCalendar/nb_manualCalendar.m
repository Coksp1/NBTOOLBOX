classdef nb_manualCalendar < nb_calendar
% Description:
%
% An object that will provide a manually provided calendar.
%
% Superclasses:
%
% nb_calendar
%
% Constructor:
%
%   obj = nb_manualCalendar(calendar)
%
%   Input:
%
%   - calendar : The manual calendar provided by the user. Must be a
%                cellstr where all elements are on the format 'yyyymmdd', 
%                e.g. {'20120101','20130101'}.
% 
% See also: 
% nb_currentCalendar, nb_getMPRVintages4
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    properties
        
        % The calendar provided by the user.
        calendar = {};
        
    end
    
    properties (Hidden=true)
        
        % The calendar as a numerical array. A cellstr where all elements 
        % are on the format 'yyyymmdd', e.g. {'20120101','20130101'}.
        calendarD = [];
        
    end
    
    methods
        
        function obj = nb_manualCalendar(calendar)
            
            if nargin < 1
                return
            end
            if isempty(calendar)
                return
            end
            if ~iscellstr(calendar)
                error([mfilename ':: The calendar input must be a cellstr.'])
            end
            calendar  = calendar(:);
            calendarD = char(calendar);
            if size(calendarD,2) ~= 8
                error([mfilename ':: Each element of the calendar must be on the format ''yyyymmdd''.'])
            end
            calendarD = str2num(calendarD); %#ok<ST2NM>
            if isempty(calendarD)
                error([mfilename ':: Each element of the calendar must be on the format ''yyyymmdd''.'])
            end
            obj.calendar  = calendar;
            obj.calendarD = calendarD;
            
        end
        
        function s = struct(obj)
            s = struct('class',   class(obj),...
                       'calendar',{obj.calendar}); 
            if obj.closed
                s.closed = obj.closed;
            end
        end
        
        function name = getName(~)
           name = 'Manual'; 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(s)
            obj = nb_manualCalendar(s.calendar);
            if isfield(s,'closed')
                obj.closed = s.closed;
            end
        end
        
    end

end
