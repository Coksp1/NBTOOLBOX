function [syntheticData,estModels] = getIndSyntheticSeries(options)
% Syntax:
%
% [syntheticData,estModels] = getIndSyntheticSeries(options)
%
% Description:
%
% Create nb_mfvar models given templates, estimate the models and retrieve
% the synthetic series.
% 
% Input:
%
% - options       : A struct with options for estimation.
%
% Output:
% 
% - syntheticData : A nb_ts object with the synthetic series from each, 
%                   model renamed to reflect the ordering from best to 
%                   worst model (i.e. options.models should already be 
%                   ordered).
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    % Run models 
    if options.parallel
        [syntheticData,estModels] = runParallel(options);
    else
        [syntheticData,estModels] = runNormal(options);
    end
    
end

%==========================================================================
function [syntheticData,estModels] = runNormal(options)

    N = length(options.models);
    
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
    
    syntheticData  = cell(1,N);
    estModels(1,N) = nb_mfvar();     
    for ii = 1:N
        
        % Estimate each of the selected models using the full sample
        model         = nb_mfvar(options.models(ii));
        estModels(ii) = estimate(model);
        series        = getCalculated(estModels(ii));
        series        = series(options.varOfInterest);
        series        = series.rename('variable',options.varOfInterest,['Model' num2str(ii)]);
        
        % Combine data
        syntheticData{ii} = series;
        
        % Update waitbar 
        if waitbar
            nb_estimator.notifyWaitbar(h,ii,N,note)
        end
        
    end
    
    % Merge
    syntheticData = [syntheticData{:}];
    
    % Delete waitbar
    if waitbar     
        nb_estimator.closeWaitbar(h);
    end
    
end

%==========================================================================
function [syntheticData,estModels] = runParallel(options)

    N = length(options.models);
    
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
    
    % Run models on full sample
    models         = options.models;
    varOfInterest  = options.varOfInterest;
    syntheticData  = cell(1,N);
    estModels(1,N) = nb_mfvar();   
    parfor ii = 1:N
        
        % Estimate each of the selected models using the full sample
        model         = nb_mfvar(models(ii));
        estModels(ii) = estimate(model);
        series        = getCalculated(estModels(ii));
        series        = series(varOfInterest);
        series        = series.rename('variable',varOfInterest,['Model' num2str(ii)]);
        
        % Combine data
        syntheticData{ii} = series;
        
        % Update waitbar 
        if waitbar 
            send(D,1); 
        end
        
    end
    
    % Merge
    syntheticData = [syntheticData{:}];
    
    % Delete waitbar
    if waitbar
        delete(h);
    end
    
end
