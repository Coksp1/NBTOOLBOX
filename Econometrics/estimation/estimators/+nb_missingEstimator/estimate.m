function [results,options] = estimate(options,check)
% Syntax:
%
% [results,options] = nb_missingEstimator.estimate(options)
%
% Description:
%
% Estimate a model with missing data (possibly with real-time data).
% 
% Input:
% 
% - options  : A struct on the format given by underlying estimators 
%              template function. See for example nb_olsEstimator.template.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' options.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        check = true;
    end
    if ~strcmpi(options.class,'nb_var')
        error([mfilename ':: Only nb_var models are supporting the ''missingMethod''',...
            'options (at least for know). Please contact NB toolbox development ',...
            'team if you need to handle missing observations for another model class.'])
    end
    start  = options.estim_start_ind;

    % Check for missing observations
    %
    % If check is false we are inside bootstrapping routine, which means 
    % that this part is already dealt with
    if check
        options               = nb_missingEstimator.checkForMissing(options,start,options.estim_end_ind);
        options.estim_end_ind = options.missingEndInd;
    end
    
    % Get the number of recursive periods
    if options.real_time_estim
        periods = size(options.data,3); 
        finish  = nan(periods,1);
        for ii = 1:periods
            [~,indV]        = nb_estimator.getVariables(options);
            notIsAllMissing = ~all(~isfinite(options.data(:,indV,ii)),2);
            finish(ii)      = find(notIsAllMissing,1,'last');
        end
    else
        if options.recursive_estim
            if isempty(options.recursive_estim_start_ind)
                error([mfilename ':: The ''recursive_estim_start_date'' must be provided if the ''missingMethod'' is non-empty.'])
            end
            periods = options.estim_end_ind - options.recursive_estim_start_ind + 1;
            finish  = options.recursive_estim_start_ind:options.estim_end_ind;
        else
            periods = 1;
            finish  = options.estim_end_ind;
        end
    end
    
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
            if isfield(options,'index')
                h = nb_waitbar5([],['Missing Data Estimation of Model '  int2str(options.index) ' of ' int2str(options.nObj) ],true);
            else
                h = nb_waitbar5([],'Missing Data Estimation',true);
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
    func    = str2func(['nb_' estim_method 'Estimator.estimate']);
    tempOpt = options;
    res     = struct;
    if options.real_time_estim
        estData                 = options.data;
        tempOpt.recursive_estim = 1;
    else
        estData = options.data(:,:,ones(1,periods));
    end
    
    % Automatic model selection?
    if ~isempty(options.modelSelection) && options.recursive_estim
        
        tempOptions                 = options;
        tempOptions.recursive_estim = false;
        tempOptions.estim_end_ind   = finish(end);
        tempOptions.data            = estData(:,:,end);
        tempOptions                 = nb_missingEstimator.fillInForMissing(tempOptions,check);
        switch estim_method
            case {'bVar','ols'}
                if strcmpi(options.class,'nb_mfvar')
                    error([mfilename ':: Model selection is not supported by mixed frequency B-VAR models.'])
                end
                minLags = [];
                if strcmpi(options.class,'nb_var')
                    minLags = 0; 
                end
                tempOptions = nb_olsEstimator.modelSelectionAlgorithm(tempOptions,minLags);
            otherwise
                error([mfilename ':: The estimator you have choosen does not support the ''modelSelection'''...
                                 ' option in combination with the ''missing'' option.'])
        end
        tempOpt.modelSelection = '';
        tempOpt.nLags          = tempOptions.nLags;
        
    end
    
    recEst  = tempOpt.recursive_estim;
    tempOpt = tempOpt(1,ones(1,periods));
    for ii = 1:periods
       
        % We trick the estimator to to recursive estimation over only one
        % period, as we only want the same output as the recursive 
        % estimation routines give us 
        tempOpt(ii).estim_end_ind = finish(ii);
        tempOpt(ii).data          = estData(:,:,ii);
        tempOpt(ii).waitbarHandle = h;
        if recEst
            tempOpt(ii).recursive_estim_start_ind = finish(ii);
        end
        
        % Fill in for missing observations
        tempOpt(ii) = nb_missingEstimator.fillInForMissing(tempOpt(ii),check);
        
        % Then we do the estimation for the given vintage/recursion
        try
            [resTemp,optEst] = func(tempOpt(ii));  
        catch Err
           nb_error([mfilename ':: Something went wrong for iteration ' int2str(ii) ' of the missing data estimation. '], Err) 
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
            if h.canceling
                error('User terminated estimation.')
            else
                h.status2 = ii;
                h.text2   = ['Finished with ' int2str(ii) ' of ' int2str(periods) ' iterations...'];
            end
        end
        
    end
    res.elapsedTime          = toc(tStart);
    res.includedObservations = outOptions(end).estim_end_ind - outOptions(end).estim_start_ind + 1;
    
    % Reset the recursive_estim_start_ind to the actual one for all
    % periods, as it is used at a later stage 
    if options.recursive_estim
        [outOptions.recursive_estim_start_ind] = deal(outOptions(1).estim_end_ind);
    end
    if isfield(res,'smoothed')
        res.filterEndDate = resTemp.filterEndDate;
    end
        
    % Assign results
    options = outOptions;
    results = res;
    
    % Delete waitbar
    if report
        deleteSecond(h)
    end

end

