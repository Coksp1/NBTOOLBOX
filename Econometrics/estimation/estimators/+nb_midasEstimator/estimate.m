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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    if options.dataFrequency <= options.frequency
        error([mfilename ':: The frequency option (' int2str(options.frequency) ') ',...
               'must be strictly lower than the frequency of the data (' int2str(options.dataFrequency) ').'])
    end
    
    % Add lags or find best model
    nExo = length(options.exogenous);
    if ~isempty(options.modelSelection)
        error([mfilename ':: The modelSelection option is not yet supported.'])
    else
        [options,freqMapping] = nb_midasEstimator.addLags(options);
        [~,indX]              = ismember(options.exogenous,options.dataVariables);
    end
    if isempty(options.polyLags)
        options.polyLags = options.nLags + 1;
        if any(strcmpi(options.algorithm,{'almon','legendre'}))
            options.polyLags(options.polyLags > 3) = 3;
        elseif strcmpi(options.algorithm,'beta')
            options.polyLags(:) = 1;
        end
        
    end
    if isscalar(options.polyLags)
        options.polyLags = repmat(options.polyLags,[1,length(options.nLags)]);
    end
    if any(strcmpi(options.algorithm,{'almon','legendre'}))
        if any(options.polyLags > 3)
            error(['No elements of polyLags can be set to a number greater than ',...
                   '3, when the algorithm option is set to ''almon'' or ''legendre''!'])
        end
    elseif strcmpi(options.algorithm,'beta')
        if any(options.polyLags > 1)
            error(['No elements of polyLags can be set to a number greater than ',...
                   '1 when, the algorithm option is set to ''beta''!'])
        end
    end
    
    % Get mapping of low frequency dependent variable in high frequency
    % data
    periods  = size(options.data,1);
    freqName = ['freq', int2str(options.frequency)];
    if isfield(freqMapping,freqName)
        mappingDep = freqMapping.(freqName);
    else
        [~,mappingDep]         = sDataDate.toDates(0:periods,'xls',options.frequency,0);
        freqMapping.(freqName) = mappingDep;
    end

    % Get estimation start and end dates
    startDateGiven = true;
    if isempty(options.estim_start_ind)
        ind = cellfun(@(x)x==options.frequency,options.frequencyExo);
        if any(ind)
            % We have regressors on the same frequency as the dependent
            % variable, so lags will need to cut the sample accordingly
            exo              = options.exogenous(1:nExo);
            exoSameFreq      = strcat(exo(ind),'_lag',strtrim(cellstr(num2str(options.nLags(ind)')))');
            [~,indXSameFreq] = ismember(exoSameFreq,options.dataVariables);
            XSameFreq        = options.data(mappingDep,indXSameFreq);
            startInMapping   = find(all(~isnan(XSameFreq),2),1,'first');
        else
            startInMapping = 1;
        end
        options.estim_start_ind = mappingDep(startInMapping);
        startDateGiven          = false;
    end
    sDate = sDataDate + (options.estim_start_ind - 1);
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end
    lDate  = convert(sDate,options.frequency);
    startL = convert(lDate,options.dataFrequency,false);
    start  = (startL - sDate) + 1;
    start  = start + options.estim_start_ind - 1;

    % Remove mapping outside estimation window
    mappingDep(mappingDep<start)                 = [];
    mappingDep(mappingDep>options.estim_end_ind) = [];
    
    % Get data
    [testY,indY] = ismember(tempDep,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
    end
    y = options.data(mappingDep,indY);
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
                options.estim_start_ind = mappingDep(locNM);
                start                   = mappingDep(locNM);
                lDate                   = lDate + (locNM - 1);
                mappingDep              = mappingDep(locNM:end);
            end
        else
            locM = find(isMissing);
        end
        locL = size(y,1);
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
    y          = y(1:end - options.yMissingEnd,:);
    mappingDep = mappingDep(1:end-options.yMissingEnd);
    if isempty(mappingDep)
        error(['The estimation start date ' toString(sDate) ' gives no ',...
            'data on the dependent variable to estimate the model on.']);
    end
    finish     = mappingDep(end);
    
    % Get the data on the exogenous
    if options.unbalanced
        
        T             = size(mappingDep,1);
        mappingExo    = nan(T,length(options.exogenous));
        Xhigh         = options.data(:,indX);
        X             = nan(T,length(options.exogenous));
        exogenousLead = nan(1,nExo);
        for ii = 1:nExo
            end_high = find(~isnan(Xhigh(:,ii)),1,'last');
            if isempty(end_high)
                error(['The exogenous variable ' options.exogenous{ii},...
                       ' does not have any valid observations!'])
            end
            d = end_high - mappingDep(end);
            if d < 0
                error(['The exogenous variable ' options.exogenous{ii},...
                       ' have less observations than the dependent variable!'])
            else
                mappingExoThis = mappingDep + d;
            end
            ind               = nb_getMidasIndex(ii,options.nLags+1,nExo);
            mappingExo(:,ind) = mappingExoThis(:,ones(1,sum(ind)));
            X(:,ind)          = Xhigh(mappingExoThis,ind);
            exogenousLead(ii) = d;
        end
        
    else
        options.estim_end_ind = finish;
        X                     = options.data(mappingDep,indX);
        mappingExo            = mappingDep(:,ones(1,length(options.exogenous)));
        exogenousLead         = zeros(1,nExo);
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
    options.mappingDep       = mappingDep;
    options.mappingExo       = mappingExo;
    options.nExo             = nExo;
    options.start_low_in_low = (lDate - sDataDateLow) + 1;
    options.end_low_in_low   = size(y,1) - 1 + options.start_low_in_low;
    options.freqMapping      = freqMapping;
    options.exogenousLead    = exogenousLead;
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

