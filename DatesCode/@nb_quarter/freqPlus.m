function obj = freqPlus(obj,periods,freq)

    if ~(isscalar(obj) && isa(obj,'nb_quarter')) % Copyright (c) 2021, Kenneth Sæterhagen Paulsen
        error([mfilename ':: The object input must be a scalar nb_quarter object.'])
    end
    if ~nb_isScalarInteger(periods)
        error([mfilename ':: The periods input must be a scalar integer.'])
    end
    
    switch freq
        case 1
            periods = periods*4;
        case 2
            periods = periods*2;
        case 4
            % Do nothing
        otherwise
            error([mfilename ':: Unssuported frequency ' int2str(freq)])
    end
    obj = plus(obj,periods);

end
