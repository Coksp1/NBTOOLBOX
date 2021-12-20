function data = nb_fetchQuasiRealTimeFinalSteps(data,inputs)
% Syntax:
%
% data = nb_fetchQuasiRealTimeFinalSteps(data,inputs)
%
% Description:
%
% Written by Kenneth Sæterhagen Paulsen and Sara Skjeggestad Meyer

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Cut the series?
    cut     = nb_parseOneOptional('cut',false,inputs{:});
    cutVint = 0;
    if cut
        today = nb_date.today(data.frequency);
        if isnumeric(cut)
            cutDate = today + cut - 1;
            cutVint = cut;
        else
            cutDate = today - 1;
            cutVint = 0;
        end
        data  = window(data,'',cutDate);
    end
  
    % Convert weekly/daily data to wanted frequency
    freq = nb_parseOneOptional('freq',[],inputs{:});
    if ~isempty(freq)
        if ~nb_isScalarInteger(freq)
            error([mfilename ':: The freq input must be a scalar integer.'])
        end
        if freq > data.frequency
            method = nb_parseOneOptional('method','none',inputs{:});
            data   = convert(data,freq,method,'interpolateDate','end');
        else
            method = nb_parseOneOptional('method','average',inputs{:});
            data   = data.convert(freq,method);
        end
    end
    
    % Get the publication dates
    start = nb_parseOneOptional('start','',inputs{:});
    if isempty(start)
        if data.frequency > 12
            m = nb_week(1,2010);
        elseif data.frequency == 12
            m = nb_month(1,2010);
        else
        	m = nb_quarter(1,2010);
        end
    else
        if nb_isOneLineChar(start)
            start = nb_date.date2freq(start);
        elseif ~isa(start,'nb_date')
            error([mfilename ':: The start input must be a one line char with the start date or a nb_date object.'])
        end
        m = start;
    end
    
    business = nb_parseOneOptional('business',false,inputs{:});
    if business
        type = 4;
    else
        type = 1;
    end
    if data.frequency > 52
        if cutVint > 0
            error('Cannot set cut to a number when loading a daily series.')
        end
        % Daily data with weekly vintages
        tm = convert(data.endDate,52);
        if m.frequency ~= tm.frequency
           m = convert(m,52);
        end
        ms       = vec(m - 1,tm);
        ms       = convert(ms,data.frequency);
        contexts = toString(ms,'xls');
        data     = window(data,'',ms(end)-1);
    else
        if data.frequency ~= m.frequency
            error([mfilename ':: The ''start'' input must be provided a date on a ' nb_date.getFrequencyAsString(data.frequency) ' frequency.'])
        end
        tm       = data.endDate + 1 - cutVint;
        ms       = vec(m,tm);
        contexts = toString(getDay(ms,type),'xls'); 
        if cutVint > 0
            ms = ms + cutVint;
        end
    end
    ms       = ms - 1;
    contexts = nb_xlsDates2FAMEVintage(contexts);
    
    % Create vintages
    data           = addPageCopies(data,ms(1:end-1));
    data.dataNames = contexts;
    
    % Do the user use the removeContext option?
    removeContext = nb_parseOneOptional('removeContext','',inputs{:});
    if ~(isempty(removeContext))
        contexts = nb_convertContexts(data.dataNames);
        if nb_isOneLineChar(removeContext)
            removeContext = nb_day(removeContext);
        elseif ~isa(removeContext,'nb_day')
            error([mfilename ':: The ''removeContext'' option must be a one line char or a nb_day object.'])
        end
        removeContext = str2double(nb_date.format2string(removeContext,'yyyymmdd'));
        ind           = removeContext <= contexts;
        data          = data(:,:,ind);
    end
    
    end
