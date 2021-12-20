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
    
    first    = convert(start,obj.frequency);
    last     = convert(finish,obj.frequency);
    periods  = last - first;
    calendar = today(ones(1,periods+1),1);
    for ii = 0:periods
        calendar(ii+1) = getDay(first + ii) + (obj.numDays - 1);
    end
    if (calendar(end) > finish)
        calendar = calendar(1:end-1);
    end
    
    if length(calendar) == 0 %#ok<ISMT>
        calendar = [];
    else
        calendar = str2num(char(nb_xlsDates2FAMEVintage(toString(calendar,'xls'))));
        calendar = nb_calendar.shrinkCalendar(calendar,start,finish);
    end
    
end
