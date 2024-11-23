function obj = freqPlus(obj,periods,freq)

    if ~(isscalar(obj) && isa(obj,'nb_semiAnnual')) % Copyright (c) 2024, Kenneth Sæterhagen Paulsen
        error([mfilename ':: The object input must be a scalar nb_semiAnnual object.'])
    end
    if ~nb_isScalarInteger(periods)
        error([mfilename ':: The periods input must be a scalar integer.'])
    end
    
    switch freq
        case 1
            obj = nb_semiAnnual(obj.halfYear,obj.year + periods);
        case 2
            obj = plus(obj,periods);
        otherwise
            error([mfilename ':: Unssuported frequency ' int2str(freq)])
    end

end
