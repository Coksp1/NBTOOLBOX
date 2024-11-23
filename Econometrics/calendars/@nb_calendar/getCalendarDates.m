function calendar = getCalendarDates(obj,frequency)
% Syntax:
%
% calendar = getCalendarDates(obj,frequency)
%
% Description:
%
% Get the dates of the calendar as a cellstr on the format
% > 'daily'    : 'yyyymmdd'
% > 'secondly' : 'yyyymmddhhnnss'
% 
% Input:
% 
% - obj       : A scalar nb_calendar object.
%
% - frequency : Either 'daily' or 'secondly'.
% 
% Output:
% 
% - calendar  : A cellstr on the format described in the description
%               of this method.
%
% See also:
% nb_calendar.getCalendar, nb_calendar.getCalendarSec
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        frequency = 'daily';
    end

    if strcmpi(frequency,'daily')
        calendar = getCalendar(obj);
    elseif strcmpi(frequency,'secondly')
        calendar = getCalendarSec(obj);
    else
        error('The frequency input must be set to ''daily'' or ''secondly''.')
    end
    calendar = cellstr(num2str(calendar));

end
