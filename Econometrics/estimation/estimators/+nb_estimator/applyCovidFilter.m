function indCovid = applyCovidFilter(options,y)
% Syntax:
%
% indCovid = nb_estimator.applyCovidFilter(options,y)
%
% Description:
%
% Apply covid filter, and return index of elements to include in
% estimation, i.e. elements set to true should be kept during estimation.
% This index is empty, if the covidAdj option is empty.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(options.covidAdj)
        indCovid = [];
        return
    end

    if strcmpi(options.estim_method,'midas')
        freq = options.frequency;
    else
        dataStartDate = nb_date.date2freq(options.dataStartDate);
        freq          = dataStartDate.frequency;
    end

    if isa(options.covidAdj,'nb_date')
        covidAdjObj = options.covidAdj;
    elseif iscellstr(options.covidAdj)
        covidAdjObj = nb_date.cell2Date(options.covidAdj,freq);
    else
        error(['The covidAdj option must be set to a cellstr or a ',...
            'vector of nb_date objects.'])
    end

    if strcmpi(options.estim_method,'midas')

        % We only give an index of the dates to remove, leads and lags are
        % taken care of inside nb_midasFunc!
        lDate = nb_date.toDate(options.estim_start_date_low,options.frequency);
        if covidAdjObj(1).frequency ~= lDate.frequency
            error(['The frequency of the dates provided to the covidAdj ',...
                'is not correct!'])
        end
        lowDates    = lDate.toDates(0:size(y,1) - 1);
        indCovidDep = ~ismember(lowDates,toString(covidAdjObj));

        % Handle lags and leads of exogenous
        exoFreqs    = [options.frequencyExo{:}];
        exoFreqsU   = unique(exoFreqs);
        indCovidExo = true(size(indCovidDep));
        for ii = 1:length(exoFreqsU)
        
            indExoThisFreq   = exoFreqsU(ii) == exoFreqs;
            if isfield(options,'options.exogenousLead')
                nLagsThisFreq = max(options.nLags(indExoThisFreq) - options.exogenousLead(indExoThisFreq)); % Correct lags for leads of exogenous variables!
            else
                nLagsThisFreq = max(options.nLags(indExoThisFreq)); % Correct lags for leads of exogenous variables!
            end
            diffFreq         = exoFreqsU(ii)/options.frequency;
            nLagsThisFreqLow = floor(nLagsThisFreq/diffFreq);
            if nLagsThisFreqLow > 0
                % Added lags means that we need to strip those periods as
                % well
                covidAdjObjThisFreq = [covidAdjObj; covidAdjObj(end).toDates(1:nLagsThisFreqLow,'nb_date')];
            else
                covidAdjObjThisFreq = covidAdjObj;
            end

            nLeadsThisFreq    = max(options.exogenousLead(indExoThisFreq)); 
            nLeadsThisFreqLow = ceil(nLeadsThisFreq/diffFreq);
            if nLeadsThisFreqLow > 0
                % Added leads means that we need to strip those periods as
                % well
                covidAdjObjThisFreq = [covidAdjObj(1).toDates(-nLeadsThisFreqLow:-1,'nb_date'); covidAdjObjThisFreq]; %#ok<*AGROW>
            end

            indCovidExo = indCovidExo & ~ismember(lowDates,toString(covidAdjObjThisFreq));

        end
        indCovid = [indCovidDep,indCovidExo];

    elseif options.nStep > 0

        % We only give an index of the dates to remove, leads and lags are
        % taken care of during estimation!
        startDate = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        if covidAdjObj(1).frequency ~= startDate.frequency
            error(['The frequency of the dates provided to the covidAdj ',...
                'is not correct!'])
        end
        lowDates    = startDate.toDates(0:size(y,1) - 1);
        indCovidDep = ~ismember(lowDates,toString(covidAdjObj));

        % Handle lags and leads of exogenous
        if iscell(options.nLags)
            nLags = options.nLags;
            nLags = cellfun(@(x)x(:),nLags,'UniformOutput',false);
            nLags = max(vertcat(nLags{:}));    
        elseif ~all(options.nLags == 0) 
            nLags = max(options.nLags);
        else
            nLags = 0;
        end
        if nLags > 0
            % Added lags means that we need to strip those periods as
            % well
            covidAdjObjThisFreq = [covidAdjObj; covidAdjObj(end).toDates(1:nLags,'nb_date')];
        else
            covidAdjObjThisFreq = covidAdjObj;
        end
        if isfield(options,'options.exogenousLead')
            nLeads = max(options.exogenousLead); 
            if nLeads > 0
                % Added leads means that we need to strip those periods as
                % well
                covidAdjObjThisFreq = [covidAdjObj(1).toDates(-nLeads:-1,'nb_date'); covidAdjObjThisFreq]; %#ok<*AGROW>
            end 
        end
        indCovidExo = ~ismember(lowDates,toString(covidAdjObjThisFreq));
        indCovid    = [indCovidDep,indCovidExo];

    elseif isempty(options.estim_types)

        startDate = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        if covidAdjObj(1).frequency ~= startDate.frequency
            error(['The frequency of the dates provided to the covidAdj ',...
                'is not correct!'])
        end

        % Handle lags and leads of exogenous
        if ~isfield(options,'nLags')
            nLags = 0;
        elseif iscell(options.nLags)
            nLags = options.nLags;
            nLags = cellfun(@(x)x(:),nLags,'UniformOutput',false);
            nLags = max(vertcat(nLags{:}));  
        elseif ~all(options.nLags == 0) 
            nLags = options.nLags;
            if isfield(options,'class')
                if strcmpi(options.class,'nb_var')
                    % See nb_olsEstimator.varModifications
                    nLags = options.nLags + 1;
                end
            end
            nLags = max(nLags);
        else
            nLags = 0;
        end
        if nLags > 0
            % Added lags means that we need to strip those periods as
            % well
            covidAdjObj = [covidAdjObj; covidAdjObj(end).toDates(1:nLags,'nb_date')];
        end

        estDates = startDate.toDates(0:size(y,1) - 1);
        indCovid = ~ismember(estDates,toString(covidAdjObj));

    else
        indCovid = [];
    end

end
