function calendar = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults) 

    if nargin < 6
        fromResults = false;
    end

    today = nb_day.today();
    if isempty(finish)
        finish = today;
    end
    if isempty(start)
        start = nb_calendar.getDefaultStart(modelGroup,doRecursive,fromResults);
    end
    if finish < start
        calendar = [];
        return
    end
    
    first = convert(start,obj.frequency);
    last  = convert(finish,obj.frequency);
    if obj.frequency == 1
        years    = (first.year:last.year)';
        monthStr = num2str(today.month);
        if size(monthStr,2) == 1
            monthStr = strcat('0',monthStr);
        end
        dayStr = num2str(today.day);
        if size(dayStr,2) == 1
            dayStr = strcat('0',dayStr);
        end
        calendar = str2num(strcat(num2str(years),monthStr,dayStr));
    else
        nrDays   = today - getDay(convert(today,obj.frequency));
        nrDaysF  = finish - getDay(last);
        if nrDaysF > nrDays
            periods  = last - first;
        else
            periods  = last - first;
        end
        calendar = today(ones(1,periods+1),1);
        for ii = 0:periods
            calendar(ii+1) = getDay(first + ii) + nrDays;
        end
        calendar = str2num(char(nb_xlsDates2FAMEVintage(toString(calendar,'xls'))));
    end
    calendar = nb_calendar.shrinkCalendar(calendar,start,finish); 
    
end
