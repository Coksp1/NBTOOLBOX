function [start,finish,start_est,startFcst] = getStartAndEnd(inputs,model,options,start,finish)
% Syntax:
%
% [start,finish,start_est,startFcst] = nb_forecast.getStartAndEnd(...
%                                       inputs,model,options,start,finish)
%
%
% Written by Kenneth Sæterhagen Paulsen

    start_est = options(end).estim_start_ind;
    if isempty(start)
        if isempty(options(end).recursive_estim_start_ind)
            start = 1;
        else 
            start = options(end).recursive_estim_start_ind - start_est + 1;
        end 
        if strcmpi(model.class,'nb_arima')
            start = start + options(end).MA;
        end
    else
        start = start - start_est;
        if strcmpi(model.class,'nb_arima')
            if start < options(end).MA
                error([mfilename ':: Cannot start forecast evalutation before the start date of estimation + ' int2str(options.MA) ' of estimation. '...
                    '(Initial values of MA terms may also be missing)'])
            end
        else
            if start < 1
                error([mfilename ':: Cannot start forecast evalutation before the start date of estimation + 1 of estimation.'])
            end
        end

        % Remove the real time estimation options before the start date 
        % of the forecast
        if numel(options) > 1
            ind = start - options(end).recursive_estim_start_ind + start_est;
            if ind < 1
                error([mfilename ':: Cannot start real-time forecast before the recursive forecast start date.'])
            end
            %options = options(ind:end);
        end

    end

    if isempty(finish)
        finish = options(end).estim_end_ind  - start_est + 1;
    else
        finish = finish - start_est;
    end
    startFcst = start + start_est:finish + start_est;
    if isempty(startFcst)
        error([mfilename ':: Cannot evaluate forecast. Start date is after the end date of estimation'])
    end    
    
    if options(end).recursive_estim
        if strcmpi(model.class,'nb_arima')
            MA    = options(end).MA;
            extra = '(Initial values of MA terms may also be missing).';
        else
            MA    = 0;
            extra = '';
        end
        if startFcst(1) < options(end).recursive_estim_start_ind + MA + 1
            startDate     = nb_date.date2freq(options(end).dataStartDate);
            startRec      = nb_date.date2freq(options(end).dataStartDate) + (options(end).recursive_estim_start_ind + MA);
            startFcstDate = startDate + (startFcst(1) - 1);
            if inputs.startIndWarning
                start            = 1 + MA;
                startFcst        = start + start_est:finish + start_est;
                startFcstDateNew = startDate + (startFcst(1) - 1);
                warning('nb_forecast:adjustStartInd',['Cannot evaluate forecast. Start date (' toString(startFcstDate) ') is before ',...
                        'the start date of recursive estimation + ' int2str(MA + 1) ' (' toString(startRec) '). ', extra,...
                        ' Reset to first possible value (' toString(startFcstDateNew) ')'])
            else
                error([mfilename ':: Cannot evaluate forecast. Start date (' toString(startFcstDate) ') is before the ',...
                    'start date of recursive estimation + ' int2str(MA + 1) ' (' toString(startRec) '). ', extra])
            end
        end
    else
        if strcmpi(model.class,'nb_arima')
            MA    = options(end).MA;
            extra = '(Initial values of MA terms may also be missing).';
        else
            MA    = 0;
            extra = '';
        end
        if startFcst(1) < options(end).estim_start_ind + MA + 1
            startDate     = nb_date.date2freq(options(end).dataStartDate);
            startRec      = start + (options(end).estim_start_ind + MA);
            startFcstDate = startDate + (startFcst(1) - 1);
            if inputs.startIndWarning
                start            = 1 + MA;
                startFcst        = start + start_est:finish + start_est;
                startFcstDateNew = startDate + (startFcst(1) - 1);
                warning('nb_forecast:adjustStartInd',['Cannot evaluate forecast. Start date (' toString(startFcstDate) ') is before the start ',...
                    'date of estimation + ' int2str(MA + 1) ' (' toString(startRec) '). ', extra,...
                    ' Reset to first possible value (' toString(startFcstDateNew) ')'])
            else
                error([mfilename ':: Cannot evaluate forecast. Start date (' toString(startFcstDate) ') is before the start ',...
                    'date of estimation + ' int2str(MA + 1) ' (' toString(startRec) '). ', extra])
            end
        end
    end
    
end
