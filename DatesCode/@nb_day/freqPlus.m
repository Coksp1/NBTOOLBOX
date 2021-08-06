function obj = freqPlus(obj,periods,freq)

    if ~(isscalar(obj) && isa(obj,'nb_day')) % Copyright (c) 2021, Kenneth Sæterhagen Paulsen
        error([mfilename ':: The object input must be a scalar nb_day object.'])
    end
    if ~nb_isScalarInteger(periods)
        error([mfilename ':: The periods input must be a scalar integer.'])
    end
    
    switch freq
        case 1
            obj = nb_day(obj.day,obj.month,obj.year + periods);
        case 2
            yearsdiff = floor((periods*6 - 1 + obj.month)/12);
            obj.year  = obj.year + yearsdiff;
            month     = obj.month + periods*6 - yearsdiff*12;
            obj       = nb_day(obj.day, month, obj.year + yearsdiff);
        case 4
            yearsdiff = floor((periods*3 - 1 + obj.month)/12);
            obj.year  = obj.year + yearsdiff;
            month     = obj.month + periods*3 - yearsdiff*12;
            obj       = nb_day(obj.day, month, obj.year + yearsdiff);
        case 12
            yearsdiff = floor((periods - 1 + obj.month)/12);
            obj.year  = obj.year + yearsdiff;
            month     = obj.month + periods - yearsdiff*12;
            obj       = nb_day(obj.day, month, obj.year + yearsdiff);
        case 52
            week = getWeek(obj) + periods;
            obj  = getDay(week,2);
        case 365
            obj = plus(obj,periods);
    end

end
