function options = crossValidate(options)
% Syntax:
%
% options = crossValidate(models,options)
%
% Description:
%
% Cross-validate models and return the top N ones according to the
% score criterion.
% 
% Input:
%
% - options : A struct with options for estimation and cross-validation.
%
% Output:
% 
% - options : A struct with updated models and (if empty) modelWeights 
%             fields.
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Run models 
    if options.parallel
        score = runParallel(options);
    else
        score = runNormal(options);
    end

    % Sort by criterion 
    [score,idx] = sort(score);
    
    if isempty(options.modelWeights)
        % If weights are not given, construct weights from score
        % criterion, giving a larger weight to better models (smaller score)
        weights              = score(1:options.nModels);
        weights              = sum(weights) ./ weights;
        options.modelWeights = (weights ./ sum(weights))';
    end
    
    % Return the best nModels
    rankedModels   = options.models(idx);
    options.models = rankedModels(1:options.nModels);
    
end

%==========================================================================
function score = runNormal(options)

    models    = options.models;
    N         = length(models);
    k         = size(options.folds,1);
    scoreFunc = @(x)scoreForecast(x,options.scoreCrit);

    % Renamed version of varofinterest used when combinging OOS forecast 
    % and withheld fold
    predName = ['PRED_',options.varOfInterest];
    
    % Store score criterion
    score = zeros(length(models),1);
    
    % Create waiting bar window
    waitbar = false;
    note    = inf;
    if options.waitbar
        h = nb_estimator.openWaitbar(options,N,false);
        if ~isempty(h)
            waitbar          = true;       
            h.lock           = 2;
            h.maxIterations3 = N;
            h.text3          = 'Starting...'; 
            note             = nb_when2Notify(N);
        else
            h = false;
        end
    else
        h = false;
    end
    
    for ii = 1:N
        
        scoreTmp = zeros(k,1);
        dataTmp  = models(ii).data;
        for jj = 1:k

            % Set data to exclude fold 
            models(ii).data = dataTmp.setToNaN(options.folds{jj,1},options.folds{jj,2},options.varOfInterest);

            % Create model and estimate
            model = nb_mfvar(models(ii));
            model = estimate(model);

            filtered = getFiltered(model);
            filtered = filtered.rename('variable',options.varOfInterest,predName);
            dTS      = [dataTmp(options.varOfInterest),filtered(predName)];
            dTS      = window(dTS,options.folds{jj,1},options.folds{jj,2});
            d        = double(dTS);
            
            % Check if we need to remove periods
            if ~isempty(options.removePeriods)
                dates = dTS.startDate:dTS.endDate;
                for kk = 1:size(options.removePeriods,1)
                    idxStart = find(ismember(dates,options.removePeriods{kk,1}));
                    idxEnd   = find(ismember(dates,options.removePeriods{kk,2}));
                    dates(idxStart:idxEnd) = [];
                    d(idxStart:idxEnd,:)   = [];
                end
            end

            % Save score criterion
            scoreTmp(jj) = scoreFunc(d(:,1)-d(:,2));
            
        end
        
        % Calculate score criterion as weigted sum: weights is a row vector
        score(ii) = options.foldWeights * scoreTmp;
        
        % Update waitbar 
        if waitbar
            nb_estimator.notifyWaitbar(h,ii,N,note)
        end
        
    end
    
    % Delete waitbar
    if waitbar     
        nb_estimator.closeWaitbar(h);
    end

end

%==========================================================================
function score = runParallel(options)

    models    = options.models;
    N         = length(models);
    k         = size(options.folds,1);
    scoreFunc = @(x)scoreForecast(x,options.scoreCrit);

    % Renamed version of varofinterest used when combinging OOS forecast 
    % and withheld fold
    predName = ['PRED_',options.varOfInterest];
    
    % Store score criterion
    score = zeros(length(models),1);
    
    % Do we want a waitbar?
    if options.waitbar
        [waitbar,D] = nb_parCheck();
        if waitbar
            h      = nb_waitbar([],'Recursive estimation',N,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        end
    else
        waitbar = false;
    end
    
    % Do cross-validation
    foldsN         = repmat({options.folds},[1,N]);
    removePeriodsN = repmat({options.removePeriods},[1,N]);
    foldWeights    = options.foldWeights;
    varOfInterest  = options.varOfInterest;

    parfor ii = 1:N

        folds         = foldsN{ii};
        removePeriods = removePeriodsN{ii};
        scoreTmp      = zeros(k,1);
        dataTmp       = models(ii).data;
        for jj = 1:k

            % Set data to exclude fold 
            models(ii).data = dataTmp.setToNaN(folds{jj,1},folds{jj,2},varOfInterest);

            % Create model and estimate
            model = nb_mfvar(models(ii));
            model = estimate(model);

            filtered = getFiltered(model);
            filtered = filtered.rename('variable',varOfInterest,predName);
            dTS      = [dataTmp(varOfInterest),filtered(predName)];
            dTS      = window(dTS,folds{jj,1},folds{jj,2});
            d        = double(dTS);
            
            % Check if we need to remove periods
            if ~isempty(removePeriods)
                dates = dTS.startDate:dTS.endDate;
                for kk = 1:size(removePeriods,1)
                    idxStart = find(ismember(dates,removePeriods{kk,1}));
                    idxEnd   = find(ismember(dates,removePeriods{kk,2}));
                    dates(idxStart:idxEnd) = [];
                    d(idxStart:idxEnd,:)   = [];
                end
            end
            
            % Save score criterion
            scoreTmp(jj) = scoreFunc(d(:,1)-d(:,2));
            
        end
        
        % Calculate score criterion as weigted sum: weights is a row vector
        score(ii) = foldWeights * scoreTmp;
        
        % Update waitbar 
        if waitbar 
            send(D,1); 
        end
        
    end
    
    % Delete waitbar
    if waitbar
        delete(h);
    end
    
end
    
%==========================================================================
function score = scoreForecast(diff,type)

        switch type
            case 'RMSE'
                score = sqrt(mean(diff.^2));
            case 'MSE'
                score = mean(diff.^2);
            case 'MAE'
                score = mean(abs(diff));
            case 'EELS'
                score = exp(mean(diff));
            case 'ESLS'
                score = exp(sum(diff));
            otherwise
                error([mfilename ':: Unrecognized score criterion. See nb_synthesizer.help(''scoreCrit'') for available types.']);
        end
end
