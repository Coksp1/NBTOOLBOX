function calendar = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults) 

    if nargin < 6
        fromResults = false;
        if nargin < 5
            doRecursive = false;
            if nargin < 4
                modelGroup = [];
                if nargin < 3
                    finish = '';
                    if nargin < 2
                        start = '';
                    end
                end
            end
        end
    end

    if isempty(obj.calendarD)
        calendar = [];
        return
    end

    if isempty(finish)
        finish = nb_day.today();
    end
    if isempty(start)
        if isempty(modelGroup)
            start = nb_day(num2str(obj.calendarD(1)));
        else
            start = nb_calendar.getDefaultStart(modelGroup,doRecursive,fromResults);
        end
    end
        
    calendar = nb_calendar.shrinkCalendar(obj.calendarD,start,finish,obj.closed);
     
end
