function obj = doFinalScore(obj)

    if obj.nContexts == 0
        obj.scores            = [];
        obj.recursiveIndex    = {};
        obj.recursiveCalendar = {};
        return
    end

    if strcmpi(obj.scoreType,'equal')
            
        % Here we just use equal weights
        if isempty(obj.nSteps)
            nSteps = max(obj.maxHor);
        else
            nSteps = obj.nSteps; 
        end
        scores = zeros(nSteps,obj.nVars,1,obj.nModels);
        for ii = 1:obj.nModels 
            if ~models(ii).valid
                continue;
            end
            [ind,indV]          = ismember(obj.vars{ii},obj.allVars);
            indV                = indV(ind);
            scores(:,indV,:,ii) = 1;
        end
        obj.recursiveIndex    = {};
        obj.recursiveCalendar = {};

    else

        % Get the calendar to use
        [index,obj.recursiveCalendar] = selectCalendar(obj.calendar,obj.model,obj.startDate,obj.endDate,obj.sub);

        % Get the score for each model
        if isempty(obj.nSteps)
            nSteps = max(obj.maxHor);
        else
            nSteps = obj.nSteps; 
        end
        scores = zeros(nSteps,obj.nVars,1,obj.nModels);
        for ii = 1:obj.nModels
            
            try
                if obj.sub
                    
                    if ~obj.model.models(ii).valid
                        continue;
                    end
                    
                    % I.e. calculate score of children
                    score = nb_scorerDefault.constructScore(obj.model.models(ii).forecastOutput,obj.allVars,index{ii},obj.scoreType,nSteps,obj.rollingWindow,obj.lambda);
                else
                    
                    if ~obj.model(ii).valid
                        continue;
                    end
                    score = nb_scorerDefault.constructScore(obj.model(ii).forecastOutput,obj.allVars,index{ii},obj.scoreType,nSteps,obj.rollingWindow,obj.lambda);
                    
                end
            catch Err
                nb_error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model '...
                                 'with name ' obj.names{ii} '.'], Err)
            end
            scores(:,:,:,ii) = score;

        end
        obj.recursiveIndex = index;
        
    end
    
    % Invert scores if wanted
    if obj.invert
        scores = 1./scores;
    end
    
    % Return scores/weights
    if ~isempty(obj.weightsFunc)
        s = size(scores);
        
        % As scores for model not yet having enough contexts are not 
        % calculated (set to nan), we need to set these nans to 0.
        scores(isnan(scores)) = 0;
        try
            obj.scores = obj.weightsFunc(scores);
        catch Err
            nb_error('The weightsFunc property returns an error when called.',Err)
        end
        if ~nb_sizeEqual(obj.scores,s)
            error([mfilename ':: The weightsFunc return an output of the wrong size.'])
        end
    else
        obj.scores = scores;
    end

end
