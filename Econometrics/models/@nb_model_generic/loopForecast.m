function fcst = loopForecast(names,sol,opt,res,startInd,endInd,nSteps,inputsW,condDB,condDBVars,shockProps,cores,writeSimulationToDisk,writeInputs)
% Syntax:
%
% [res,estOpt] = nb_model_generic.loopForecast(names,sol,opt,res,...
%                   startInd,endInd,nSteps,inputsW,condDB,condDBVars,...
%                   shockProps,cores,writeSimulationToDisk,writeInputs)
%
% Description:
%
% Loop forecasting of models. Called inside forecast method.
% 
% See also:
% nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set up file to write if asked for
    writeInputs = nb_logger.openLoggerFile(writeInputs);
    if isfield(inputsW(1),'waitbar')
        waitbar = inputsW(1).waitbar;
    else
        waitbar = false;
    end
    
    nobj = length(sol);
    if isscalar(nSteps)
        nSteps = nSteps(1,ones(1,nobj));
    end
    fcst = cell(1,nobj);
    if nobj == 0
        return
    end
    if inputsW(1).parallel

        [useNew,D] = nb_parCheck();
        ret        = nb_openPool(cores);
        write      = writeInputs.write;
        if useNew % R2017B allows for waitbar in parfor!
            
            % Create waitbar and create notify function
            h      = nb_waitbar([],'Forecasting',nobj,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
            [inputsW(:).waitbar] = deal([]);
            
            % Build a WorkerObjWrapper object to write to a worker specific
            % file if you want the errors to be written to a file
            if write
                w = nb_logger.getParallellLoggerFile('Forecast');
            else
                w = []; 
            end
            
            parfor ii = 1:nobj
                try
                    fcst{ii} = nb_forecast(sol{ii},opt{ii},res{ii},startInd{ii},endInd{ii},nSteps(ii),inputsW(ii),condDB{ii},condDBVars{ii},shockProps{ii});
                    if writeSimulationToDisk
                        fcst{ii} = nb_model_generic.writeSimulationToDisk(fcst{ii},ii);
                    end
                catch Err
                    message = ['Error while forecasting model; ' names{ii} '::'];
                    nb_logger.loggingDuringParallel(nb_logger.ERROR,write,w,message,Err);
                end 
                send(D,1); % Update waitbar
            end
            
            if write
                delete(w);
                clear w; % causes "fclose(w.Value)" to be invoked on the workers  
            end
            delete(h);
            
        else % Old version where files are used!
            
            % Build a WorkerObjWrapper object to write to a worker specific
            % file
            w = nb_funcToWrite('forecast_worker','gui');
            [inputsW(:).waitbar] = deal(w);

            parfor ii = 1:nobj
                fprintf(w.Value,['Forecast of Model '  int2str(ii) ' of ' int2str(nobj) ' started.\r\n']);  %#ok<PFBNS>
                try
                    fcst{ii} = nb_forecast(sol{ii},opt{ii},res{ii},startInd{ii},endInd{ii},nSteps(ii),inputsW(ii),condDB{ii},condDBVars{ii},shockProps{ii});
                    if writeSimulationToDisk
                        fcst{ii} = nb_model_generic.writeSimulationToDisk(fcst{ii},ii);
                    end
                catch Err
                    message = ['Error while forecasting model; ' names{ii} '::'];
                    nb_logger.loggingDuringParallel(nb_logger.ERROR,write,w,message,Err);
                end
                nb_logger.loggingDuringParallel(nb_logger.INFO,write,w,['Forecast of model '  int2str(ii) ' of ' int2str(nobj) ' finished.\r\n']);  
            end
            delete(w);
            clear w; % causes "fclose(w.Value)" to be invoked on the workers 
            
        end
        nb_closePool(ret);

    elseif waitbar

        % Initialize waitbar
        h                    = nb_waitbar5([],'Forecasting',true);
        h.text5              = 'Starting...';
        h.maxIterations5     = nobj;
        [inputsW(:).waitbar] = deal(h);
        notify               = nb_when2Notify(nobj);
        for ii = 1:nobj
            try
                fcst{ii} = nb_forecast(sol{ii},opt{ii},res{ii},startInd{ii},endInd{ii},nSteps(ii),inputsW(ii),condDB{ii},condDBVars{ii},shockProps{ii});
                if writeSimulationToDisk
                    fcst{ii} = nb_model_generic.writeSimulationToDisk(fcst{ii},ii);
                end
            catch Err
                message = ['Error while forecasting model; ' names{ii} '::'];
                if ~writeInputs.write
                    % Close waitbar if error is thrown
                    nb_closeWaitbar5();
                end
                nb_logger.logging(nb_logger.ERROR,writeInputs,message,Err); 
            end
            if rem(ii,notify) == 0
                h.status5 = ii;
                h.text5   = ['Model '  int2str(ii) ' of ' int2str(nobj) ' finished.'];
            end
        end
        delete(h);

    else
        inputsW = rmfield(inputsW,'waitbar');
        for ii = 1:nobj
            try
                fcst{ii} = nb_forecast(sol{ii},opt{ii},res{ii},startInd{ii},endInd{ii},nSteps(ii),inputsW(ii),condDB{ii},condDBVars{ii},shockProps{ii});
                if writeSimulationToDisk
                    fcst{ii} = nb_model_generic.writeSimulationToDisk(fcst{ii},ii);
                end
            catch Err
                message = ['Error while forecasting model; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,writeInputs,message,Err);
                if writeInputs.write
                    nb_closeWaitbar5();
                end
            end
        end
    end

    % Close written file
    nb_logger.closeLoggerFile(writeInputs);

end
