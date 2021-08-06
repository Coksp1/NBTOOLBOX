function calendar = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults) 

    if nargin < 6
        fromResults = false;
    end

    if isempty(finish)
        finish = nb_day.today();
    end
    if isempty(start)
        start = nb_calendar.getDefaultStart(modelGroup,doRecursive,fromResults);
    end
        
    calendar = nb_calendar.shrinkCalendar(obj.calendarD,start,finish);
     
end
