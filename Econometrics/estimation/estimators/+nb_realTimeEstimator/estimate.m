function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_realTimeEstimator.estimate(options)
%
% Description:
%
% Estimate a model with real-time data.
% 
% Caution : May run estimation in parallel on a given set of cores.
%
% Input:
% 
% - options  : A struct on the format given by underlying estimators 
%              template function. See for example nb_olsEstimator.template.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' options.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'parallel',false);
    options = nb_defaultField(options,'cores',[]);
    
    % Get data
    real_time_data = options.data;
    periods        = size(real_time_data,3);
    
    % Create waiting bar window
    report = false;
    if periods ~= 1
        if isfield(options,'waitbarHandle')
            if strcmpi(options.waitbarHandle,'none')
                h = []; % In parallel mode
            else
                h = options.waitbarHandle;
            end
        else
            if options.parallel
                h = []; % In parallel mode
            else
                if isfield(options,'index')
                    h = nb_waitbar5([],['Recursive Real-time Estimation of Model '  int2str(options.index) ' of ' int2str(options.nObj) ],true);
                else
                    h = nb_waitbar5([],'Recursive Real-time Estimation',true);
                end 
            end
        end
        if ~isempty(h)
            h.maxIterations2 = periods;
            h.text2          = 'Starting...';
            report           = true;
        end
    else
        h = [];
    end
    
    tStart = tic;

    % Get options shared by the recursive periods, and get a hold on the
    % real time data
    estim_method = lower(options.estim_method);
    if strcmpi(estim_method,'bvar')
        estim_method = 'bVar';
    end
    func = str2func(['nb_' estim_method 'Estimator.estimate']);
    
    % Automatic model selection?
    modSel = false;
    if isfield(options,'modelSelection')
        modSel = ~isempty(options.modelSelection);
    end
    tempOpt  = options;
    if modSel && options.recursive_estim
        
        tempData                    = real_time_data(:,:,end);
        isFinite                    = isfinite(tempData);
        endInd                      = find(all(isFinite,2),1,'last');
        tempOptions                 = options;
        tempOptions.recursive_estim = false;
        tempOptions.estim_end_ind   = endInd;
        tempOptions.data            = tempData;
        switch estim_method
            case {'bVar','ols'}
                tempOptions = nb_olsEstimator.modelSelectionAlgorithm(tempOptions);
            otherwise
                error([mfilename ':: The estimator you have choosen does not support the ''modelSelection'''...
                                 ' option in combination with the real-time data.'])
        end
        tempOpt.modelSelection = '';
        tempOpt.nLags          = tempOptions.nLags;
        
    end
    
    tempOpt.recursive_estim = 1;
    
    if options.parallel
        
        ret = nb_openPool(options.cores);
        w   = nb_funcToWrite('real_time_estimation_worker','gui');
        
        % Initial check of data (Cannot be parallelized)
        func   = {func};
        func   = func(1,ones(1,periods));
        endInd = nan(1,periods);
        data   = cell(1,periods);
        for ii = 1:periods
        
            % Find the last valid data point for the given vintage
            tempData   = real_time_data(:,:,ii);
            isFinite   = isfinite(tempData);
            endInd(ii) = find(all(isFinite,2),1,'last');
            if ii ~= 1
                if endInd(ii) ~= endInd(ii-1) + 1
                    error([mfilename ':: The provided dataset does not provide a new observation for all variables for the page ' int2str(ii) ])
                end
            end
            data{ii} = tempData;
            
        end
            
        resP = cell(1,periods);
        opt  = repmat({tempOpt},[1,periods]);
        parfor ii = 1:periods

            % We trick the estimator to do recursive estimation over only one
            % period, as we only want the same output as the recursive 
            % estimation routines give us 
            opt{ii}.estim_end_ind             = endInd(ii);
            opt{ii}.recursive_estim_start_ind = endInd(ii);
            opt{ii}.data                      = data{ii};
            opt{ii}.waitbar                   = false;
            opt{ii}.waitbarHandle             = 'none';
            
            % As some estimators store down files to disk we need to
            % set a unique name for each period, so as to prevent different
            % workers to save to the same file!
            if isfield(opt{ii},'name')
                if isempty(opt{ii}.name)
                    opt{ii}.name = ['rec', int2str(ii)];
                else
                    opt{ii}.name = [opt{ii}.name,'_rec', int2str(ii)]
                end
            end
            
            % Then we do the estimation for the given vintage
            try
                [resP{ii},opt{ii}] = func{ii}(opt{ii});  
            catch Err
                nb_error([mfilename ':: Something went wrong for iteration ' int2str(ii) ' of the real-time estimation.'],Err) 
            end
            
            % Update the status 
            fprintf(w.Value,['Estimation of Model '  int2str(ii) ' of ' int2str(periods) ' iterations...\r\n']);  %#ok<PFBNS>

        end
        
        delete(w);
        clear w; % causes "fclose(w.Value)" to be invoked on the workers 
        nb_closePool(ret);
        
        % Merge results (Cannot be parallelized)
        outOptions = [opt{:}];
        res        = struct;
        for ii = 1:periods
            res = nb_realTimeEstimator.mergeResults(res,resP{ii});
        end
        
    else % Not parallel
        
        notify  = nb_when2Notify(periods);
        tempOpt = tempOpt(1,ones(1,periods));
        res     = struct;
        for ii = 1:periods

            % Find the last valid data point for the given vintage
            tempData = real_time_data(:,:,ii);
            isFinite = isfinite(tempData);
            endInd   = find(all(isFinite,2),1,'last');
            if ii ~= 1
                if endInd ~= endIndOld + 1
                    error([mfilename ':: The provided dataset does not provide a new observation for all variables for the page ' int2str(ii) ])
                end
            end

            % We trick the estimator to do recursive estimation over only one
            % period, as we only want the same output as the recursive 
            % estimation routines give us 
            tempOpt(ii).estim_end_ind             = endInd;
            tempOpt(ii).recursive_estim_start_ind = endInd;
            tempOpt(ii).data                      = tempData;
            tempOpt(ii).waitbarHandle             = h;

            % Then we do the estimation for the given vintage
            try
                [resTemp,optEst] = func(tempOpt(ii));  
            catch Err
                nb_error([mfilename ':: Something went wrong for iteration ' int2str(ii) ' of the real-time estimation.'],Err) 
            end
            optEst = rmfield(optEst,'waitbarHandle');

            % We now need to merge the results
            if ii == 1
                outOptions = optEst(1,ones(1,periods));
            end
            res            = nb_realTimeEstimator.mergeResults(res,resTemp);
            outOptions(ii) = optEst;

            % Update the status of the wait bar
            if report
                if rem(ii,notify) == 0
                    h.status2 = ii;
                    h.text2   = ['Finished with ' int2str(ii) ' of ' int2str(periods) ' iterations...'];
                end
            end
            endIndOld = endInd; 

        end
        
    end
    
    res.elapsedTime = toc(tStart);
    res.includedObservations = outOptions(end).estim_end_ind - outOptions(end).estim_start_ind + 1;
    
    % Reset the recursive_estim_start_ind to the actual one for all
    % periods, as it is used at a later stage 
    [outOptions.recursive_estim_start_ind] = deal(outOptions(1).estim_end_ind);
    
    % Assign results
    options = outOptions;
    results = res;
    
    % Delete waitbar
    if report
        deleteSecond(h)
    end
    
end

