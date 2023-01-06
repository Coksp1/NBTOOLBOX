function obj = freqPlus(obj,periods,freq)

    if ~(isscalar(obj) && isa(obj,'nb_day')) % Copyright (c) 2023, Kenneth Sæterhagen Paulsen
        error([mfilename ':: The object input must be a scalar nb_day object.'])
    end
    if ~nb_isScalarInteger(periods)
        error([mfilename ':: The periods input must be a scalar integer.'])
    end
    
    switch freq
        case 1
            maxDay = nb_day.getNumberOfDaysInMonth(obj.month,obj.leapYear);
            if obj.day > maxDay
                day = maxDay;
            else
                day = obj.day;
            end
            obj = nb_day(day,obj.month,obj.year + periods);
        case 2
            yearsdiff = floor((periods*6 - 1 + obj.month)/12);
            year      = obj.year + yearsdiff;
            month     = obj.month + periods*6 - yearsdiff*12;
            maxDay    = nb_day.getNumberOfDaysInMonth(month,nb_year.isLeapYear(year));
            if obj.day > maxDay
                day = maxDay;
            else
                day = obj.day;
            end
            obj = nb_day(day, month, year);
        case 4
            yearsdiff = floor((periods*3 - 1 + obj.month)/12);
            year      = obj.year + yearsdiff;
            month     = obj.month + periods*3 - yearsdiff*12;
            maxDay    = nb_day.getNumberOfDaysInMonth(month,nb_year.isLeapYear(year));
            if obj.day > maxDay
                day = maxDay;
            else
                day = obj.day;
            end
            obj = nb_day(day, month, year);
        case 12
            yearsdiff = floor((periods - 1 + obj.month)/12);
            month     = obj.month + periods - yearsdiff*12;
            year      = obj.year + yearsdiff;
            maxDay    = nb_day.getNumberOfDaysInMonth(month,nb_year.isLeapYear(year));
            if obj.day > maxDay
                day = maxDay;
            else
                day = obj.day;
            end
            obj = nb_day(day, month, year);
        case 52
            week = getWeek(obj) + periods;
            obj  = getDay(week,2);
        case 365
            obj = plus(obj,periods);
    end

end
