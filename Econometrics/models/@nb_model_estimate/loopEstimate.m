function [res,estOpt] = loopEstimate(estOpt,names,inputs)
% Syntax:
%
% [res,estOpt] = nb_model_estimate.loopEstimate(estOpt,names,inputs)
%
% Description:
%
% Loop estimation of models. Called inside estimate method.
% 
% See also:
% nb_model_estimate.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        inputs = struct(...
            'parallel', false,...
            'waitbar', false,...
            'write', false);
    end

    % Set up file to write if asked for
    inputs = nb_logger.openLoggerFile(inputs);

    % Estimate the model(s)
    nobj = length(estOpt);
    res  = cell(1,nobj);
    if nobj == 0
        return
    end
    if inputs.parallel

        [useNew,D] = nb_parCheck();
        ret        = nb_openPool(inputs.cores);
        write      = inputs.write;
        if useNew % R2017B allows for waitbar in parfor!
        
            % Create waitbar and create notify function
            h      = nb_waitbar([],'Estimation',nobj,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        
            % Build a WorkerObjWrapper object to write to a worker specific
            % file if you want the errors to be written to a file
            if write
                w = nb_logger.getParallellLoggerFile('Estimation');
            else
                w = []; 
            end
                
            parfor ii = 1:nobj
                estOpt{ii}.index         = ii;
                estOpt{ii}.nObj          = nobj;
                estOpt{ii}.waitbarHandle = 'none';
                estOpt{ii}.parallel      = false; % Cannot run parallel at a lower level at the same time!
                try
                    [res{ii},estOpt{ii}] = nb_model_estimate.estimateOneLoop(estOpt{ii});
                catch Err
                    message = ['Error while estimating model; ' names{ii} '::'];
                    nb_logger.loggingDuringParallel(nb_logger.ERROR,write,w,message,Err); 
                end
                send(D,1); % Update waitbar
            end
            
            delete(h);
            if write
                delete(w);
                clear w; % causes "fclose(w.Value)" to be invoked on the workers  
            end
             
        else % This is the old version where the progress is written to different files!
            
            % Build a WorkerObjWrapper object to write to a worker specific
            % file
            w = nb_funcToWrite('estimation_worker','gui');
            parfor ii = 1:nobj
                estOpt{ii}.index         = ii;
                estOpt{ii}.nObj          = nobj;
                estOpt{ii}.waitbarHandle = 'none';
                estOpt{ii}.parallel      = false; % Cannot run parallel at a lower level at the same time!
                try
                    [res{ii},estOpt{ii}] = nb_model_estimate.estimateOneLoop(estOpt{ii});
                catch Err
                    message = ['Error while estimating model; ' names{ii} '::'];
                    nb_logger.loggingDuringParallel(nb_logger.ERROR,write,w,message,Err); 
                end 
                nb_logger.loggingDuringParallel(nb_logger.INFO,write,w,['Estimation of model '  int2str(ii) ' of ' int2str(nobj) ' finished.\r\n']); 
            end
            delete(w);
            clear w; % causes "fclose(w.Value)" to be invoked on the workers 
            
        end
        
        nb_closePool(ret);

    elseif inputs.waitbar

        % Initialize waitbar
        if nobj > 0
            h                = nb_waitbar5([],'Estimation',true);
            h.text1          = 'Starting...';
            h.maxIterations1 = nobj;
            notify           = nb_when2Notify(nobj);
            for ii = 1:nobj
                estOpt{ii}.index         = ii;
                estOpt{ii}.nObj          = nobj;
                estOpt{ii}.waitbarHandle = h;
                try
                    [res{ii},estOpt{ii}] = nb_model_estimate.estimateOneLoop(estOpt{ii});
                catch Err
                    message = ['Error while estimating model; ' names{ii} '::'];
                    nb_logger.logging(nb_logger.ERROR,inputs,message,Err); 
                end
                if rem(ii,notify) == 0
                    h.status1 = ii;
                    h.text1   = ['Estimation of Model '  int2str(ii) ' of ' int2str(nobj) ' finished.'];   
                end
            end
            delete(h);
        end

    else

        for ii = 1:nobj  
            estOpt{ii}.index = ii;
            estOpt{ii}.nObj  = nobj;
            try
                [res{ii},estOpt{ii}] = nb_model_estimate.estimateOneLoop(estOpt{ii});  
            catch Err
                message = ['Error while estimating model; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);   
            end
        end

    end

    % Close written file
    nb_logger.closeLoggerFile(inputs);

end
