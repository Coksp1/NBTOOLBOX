function obj = doRecursiveScore(obj)

    if obj.nContexts == 0
        obj.scores            = [];
        obj.recursiveIndex    = {};
        obj.recursiveCalendar = {};
        return
    end
        
    if obj.sub
        models = obj.model.models;
    else
        models = obj.model;
    end
    
    if strcmpi(obj.scoreType,'equal')
            
        % Here we just use equal weights
        if isempty(obj.nSteps)
            nSteps = max(obj.maxHor);
        else
            nSteps = obj.nSteps; 
        end
        scores = zeros(nSteps,obj.nVars,obj.nContexts,obj.nModels);
        for ii = 1:obj.nModels
            if ~models(ii).valid
                continue;
            end
            [ind,indV] = ismember(obj.vars{ii},obj.allVars);
            indV       = indV(ind);
            first      = 1;
            while ~strcmp(models(ii).forecastOutput.context{1}, obj.allContexts{first})
                first = first + 1;
            end
            scores(:,indV,first:end,ii) = 1;
        end
        obj.recursiveIndex    = {};
        obj.recursiveCalendar = {};

    else

        % Get the calendar to use
        contextDates                  = nb_date.cell2Date(obj.allContexts,365);
        [index,obj.recursiveCalendar] = selectRecursiveCalendar(obj.calendar,obj.model,obj.startDate,contextDates,obj.sub);

        % Get the score for each model
        if isempty(obj.nSteps)
            nSteps = max(obj.maxHor);
        else
            nSteps = obj.nSteps; 
        end
        scores = zeros(nSteps,obj.nVars,obj.nContexts,obj.nModels);
        for ii = 1:obj.nModels
            
            if ~models(ii).valid
                continue;
            end
            
            for jj = 1:length(index{ii})
                
                if length(index{ii}{jj}) < obj.nVintagesMin
                    % If too few evaluation points, we skip the model
                    continue
                end
                try
                    score = nb_scorerDefault.constructScore(models(ii).forecastOutput,obj.allVars,index{ii}{jj},obj.scoreType,nSteps,obj.rollingWindow,obj.lambda);
                catch Err
                    nb_error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model '...
                                     'with name ' obj.names{ii} '.'], Err)
                end
                scores(:,:,jj,ii) = real(score);
                
            end
            
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
