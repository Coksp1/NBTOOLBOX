function [weekNum,weekDay,yearN] = getWeekNumber(obj)
% Syntax:
%
% [weekNum,weekDay,yearN] = getWeekNumber(obj)
%
% Description:
%
% Get week number and weekday of a nb_day object.
% 
% Input:
% 
% - obj : A nb_day object.
% 
% Output:
% 
% - weekNum : The week number that the day is in. As a double. 
%
% - weekDay : The weekday of the day. As an integer. Sun: 1, Mon: 2, Tue:   
%             3, Wed: 4, Thu: 5, Fri: 6, Sat: 7.
%
% - yearN   : The year of the day, as a double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen         

    weekDay               = rem(6 + [obj.dayNr],7);
    weekDay(weekDay == 0) = 7;
    weekDay(weekDay < 0)  = 7 + weekDay(weekDay < 0);
    weekDayCalc           = weekDay - 1;
    if weekDayCalc == 0
        weekDayCalc = 7;
    end
    ordD    = nb_week.getOrdinalDate(obj.day,obj.month,obj.isLeapYear());
    weekNum = floor((ordD - weekDayCalc + 10)/7);

    % When the formula above return 53 we must check if the
    % week should be the 53rd week of this year or the
    % the 1st of the next.
    yearN = obj.year;
    if weekNum == 53
        weekDayEndOfYear = weekDay - 1 + 31 - obj.day;
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
