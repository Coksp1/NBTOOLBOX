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
   
    today = nb_day.today();
    if isempty(finish)
        finish = today;
    end
    if isempty(start)
        if isempty(modelGroup)
            start = nb_day(1,1,2000);
        else
            start = nb_calendar.getDefaultStart(modelGroup,doRecursive,fromResults);
        end
    end
    
    if obj.frequency == 52
        inp = 2;
    else
        inp = 1;
    end
    
    first = convert(start,obj.frequency);
    last  = convert(finish,obj.frequency);
    if last < first
        calendar = [];
        return
    end
    
    periods  = last - first;
    calendar = today(ones(1,periods+1),1);
    for ii = 0:periods
        calendar(ii+1) = getDay(first + ii,inp) + (obj.numDays - 1);
    end
    if obj.closed
        if (calendar(end) > finish)
            calendar = calendar(1:end-1);
        end
    else
        if (calendar(end) < finish)
            lastCalendarDate = getDay(first + periods + 1,inp) + (obj.numDays - 1);
            calendar         = [calendar;lastCalendarDate];
        end
    end
    
    if length(calendar) == 0 %#ok<ISMT>
        calendar = [];
    else
        calendar = str2num(char(nb_xlsDates2FAMEVintage(toString(calendar,'xls'))));
        calendar = nb_calendar.shrinkCalendar(calendar,start,finish);
    end
    
end
