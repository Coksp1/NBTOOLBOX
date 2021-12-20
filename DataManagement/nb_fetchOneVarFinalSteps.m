function data = nb_fetchOneVarFinalSteps(data,sourceType,inputs)
% Syntax:
%
% data = nb_fetchOneVarFinalSteps(data,inputs)
%
% Written by Kenneth Sæterhagen Paulsen and Sara Skjeggestad Meyer

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    % Convert frequency
    freq = nb_parseOneOptional('freq',[],inputs{:});
    if ~isempty(freq)
        if ~nb_isScalarInteger(freq)
            error([mfilename ':: The freq input must be a scalar integer.'])
        end
        if freq > data.frequency
            method = nb_parseOneOptional('method','none',inputs{:});
            data   = convert(data,freq,method,'interpolateDate','end');
        elseif freq < data.frequency
            realEnd   = getRealEndDatePages(data,'nb_date');
            startLow  = convert(realEnd(1),freq);
            endLow    = convert(realEnd(end),freq);
            datesLow  = vec(startLow,endLow);
            highInLow = convert(datesLow,data.frequency,0);
            [ind,loc] = ismember(highInLow,realEnd);
            loc       = loc(ind);
            method    = nb_parseOneOptional('method','average',inputs{:});
            data      = convert(data(:,:,loc),freq,method);
        end
        
    end
    
    % Re-indexing the series?
    reIndexSeries = nb_parseOneOptional('reIndex',false,inputs{:});
    if reIndexSeries && ~strcmpi(sourceType,'smart')
        date = min(getRealEndDatePages(data,'nb_date'));
        data = reIndex(data,date);
    end
    
end
