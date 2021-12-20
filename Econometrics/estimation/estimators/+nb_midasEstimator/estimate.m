function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_midasEstimator.estimate(options)
%
% Description:
%
% Estimate a MIDAS model with wanted algorithm.
% 
% Input:
% 
% - options  : A struct on the format given by nb_midasEstimator.template.
%              See also nb_midasEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_midasEstimator.print, nb_midasEstimator.help, nb_midasEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    options = nb_defaultField(options,'modelSelection','');
    options = nb_defaultField(options,'polyLags',[]);
    options = nb_defaultField(options,'unbalanced',false);
    if isempty(options.polyLags)
        options.polyLags = options.nLags + 1;
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    options.exogenous = cellstr(options.exogenous);
    
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end
    options.modelSelectionFixed = false(1,length(options.exogenous));

    % Get the estimation data
    %------------------------------------------------------
    [sDataDate,options.dataFrequency] = nb_date.date2freq(options.dataStartDate);
    sDataDateLow                      = convert(sDataDate,options.frequency);

    % Add lags or find best model
    if ~isempty(options.modelSelection)
        error([mfilename ':: The modelSelection option is not yet supported.'])
    else
        nExo = length(options.exogenous);
        if ~nb_isScalarInteger(options.nLags)
            error([mfilename ':: The nLags input must be a scalar.'])
        end
        options  = nb_midasEstimator.addLags(options);
        [~,indX] = ismember(options.exogenous,options.dataVariables);
    end

    % Get estimation start and end dates
    startDateGiven = true;
    if isempty(options.estim_start_ind)
        startInd = find(~any(isnan(options.data(:,indX)),2),1);
        sDateInd = sDataDate + startInd;
        switch options.frequency
            case 4
                lDate  = sDateInd.getQuarter();
                startL = lDate.getMonth(false);
                start  = (startL - sDateInd) + 1;
            case 1
                if options.dataFrequency == 12
                    lDate  = sDateInd.getYear();
                    startL = lDate.getMonth(false);
                    start  = (startL - sDateInd) + 1;
                else
                    lDate  = sDateInd.getYear();
                    startL = lDate.getQuarter(false);
                    start  = (startL - sDateInd) + 1;
                end
            otherwise
                error([mfilename ':: The frequency of the dependent variable can only be 1 (yearly) or 4 (quarterly).'])
        end
        options.estim_start_ind = startInd + start;
        startDateGiven          = false;
    end
    sDate = sDataDate + (options.estim_start_ind - 1);
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end
    if options.dataFrequency <= options.frequency
        error([mfilename ':: The frequency option (' int2str(options.frequency) ') must be strictly lower than the frequency of the data (' int2str(options.dataFrequency) ').'])
    end
    if options.dataFrequency > 12
        error([mfilename ':: The frequency of the data cannot be higher than monthly.'])
    end
    switch options.frequency
        case 4
            lDate  = sDate.getQuarter();
            startL = lDate.getMonth(false);
            start  = (startL - sDate) + 1;
            incr   = 3;
        case 1
            if options.dataFrequency == 12
                lDate  = sDate.getYear();
                startL = lDate.getMonth(false);
                start  = (startL - sDate) + 1;
                incr   = 12;
            else
                lDate  = sDate.getYear();
                startL = lDate.getQuarter(false);
                start  = (startL - sDate) + 1;
                incr   = 4;
            end
        otherwise
            error([mfilename ':: The frequency of the dependent variable can only be 1 (yearly) or 4 (quarterly).'])
    end
    start = start + options.estim_start_ind - 1;

    % Get data
    [testY,indY] = ismember(tempDep,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
    end
    y = options.data(start:incr:options.estim_end_ind,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    isMissing = isnan(y);
    if any(isMissing)
        locNM = find(~isMissing,1);
        if locNM ~= 1
            if startDateGiven
                error([mfilename ':: MIDAS models cannot handle missing observation of the dependent variable in the start or in the middle of the sample.'])
            else
                % Missing observation at the start, so we just remove these
                % if start date is not given
                locM                    = find(isMissing(locNM:end));
                y                       = y(locNM:end);
                options.estim_start_ind = options.estim_start_ind + incr*(locNM-1);
                start                   = start + incr*(locNM-1);
                lDate                   = lDate + (locNM - 1);
            end
        else
            locM = find(isMissing);
        end
        locL = length(isMissing) + 1;
        for ii = length(locM):-1:1
            if locL - locM(ii) > 1
                error([mfilename ':: MIDAS models cannot handle missing observation of the dependent variable in the start or in the middle of the sample.'])
            end
            locL = locM(ii);
        end
        options.yMissingEnd = length(locM);
    else
        options.yMissingEnd = 0;
    end

    % Correct for missing observation at the end of the dependent variable
    y      = y(1:end - options.yMissingEnd,:);
    finish = start + size(y,1)*incr - incr;
    
    % Get the data on the exogenous
    if options.unbalanced
        X          = options.data(:,indX);
        end_high   = find(~any(isnan(X),2),1,'last');
        dHigh      = end_high - finish;
        if dHigh > incr
            % Here we prevent the exogenous to lead more than one period
            % at the low frequency
            dHigh    = incr;
            end_high = finish + incr;
        end
        start_high = start + dHigh;
        X          = X(start_high:incr:end_high,:);
    else
        X          = options.data(start:incr:options.estim_end_ind,indX);
        X          = X(1:end - options.yMissingEnd,:);
        dHigh      = 0;
        start_high = start;
        end_high   = finish;
    end
    if size(X,2) == 0
        error([mfilename ':: You must select some regressors.'])
    end
    if any(isnan(X(:)))
        error([mfilename ':: The MIDAS estimator does not support missing observation on the exogenous variables.'])
    end
    
    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end
    
    % Do the estimation
    %------------------------------------------------------
    options.start_low        = start;
    options.end_low          = finish;
    options.start_high       = start_high;
    options.end_high         = end_high;
    options.exogenousLead    = dHigh;
    options.increment        = incr;
    options.nExo             = nExo;
    options.start_low_in_low = (lDate - sDataDateLow) + 1;
    options.end_low_in_low   = size(y,1) - 1 + options.start_low_in_low;
    if options.recursive_estim    
        [results,options] = nb_midasEstimator.recursiveEstimation(options,y,X,nExo);
    else % Not recursive
        [results,options] = nb_midasEstimator.normalEstimation(options,y,X,nExo); 
    end
    
    % Assign generic results
    results.includedObservations = size(y,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_midasEstimator';
    options.estimType = 'classic';
    
    % Estimation dates in low frequency
    options.estim_start_date_low = toString(lDate);
    options.estim_end_date_low   = toString(lDate + (size(y,1) - 1));
    
end

