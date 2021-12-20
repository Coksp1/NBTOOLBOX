function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_risedsgeEstimator.estimate(options)
%
% Description:
%
% Estimate a dsge model using the RISE toolbox made by Junior Maih.
% 
% Input:
% 
% - options  : A struct on the format given by nb_risedsgeEstimator.template.
%              See also nb_risedsgeEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_risedsgeEstimator.print, nb_risedsgeEstimator.help, 
% nb_risedsgeEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

    % Get the estimation options
    %------------------------------------------------------
    tempObs  = cellstr(options.riseObject.observables.name);
    dataVars = options.dataVariables;
    ind      = ismember(tempObs,dataVars);
    if ~all(ind)
        error([mfilename ':: All the observables of the model is not provided with data before estimation.'])
    end
    
    % Get the estimation data
    %------------------------------------------------------
    data_ts = struct();
    data    = options.data;
    sDate   = options.dataStartDate;
    for ii = 1:length(dataVars)
        data_ts.(dataVars{ii}) = ts(sDate,permute(data(:,ii,:),[1,3,2]));
    end
    
    % Check the priors
    %------------------------------------------------------
    estimated  = fieldnames(options.prior);
    param      = options.riseObject.parameter_values(options.riseObject.parameters.is_in_use);
    hasNoValue = isnan(param);
    if any(hasNoValue)
       
        paramNames             = options.riseObject.parameters.name(options.riseObject.parameters.is_in_use);
        paramNamesWithoutValue = paramNames(hasNoValue);
        paramInd               = ismember(paramNamesWithoutValue,estimated);
        paramError             = paramNamesWithoutValue(~paramInd);
        if ~isempty(paramError)
            error([mfilename ':: Some parameters of the DSGE/RISE model are not calibrated and not assign a prior either; '...
                   nb_cellstr2String(paramError,', ',' and ')])
        end
        
    end
    
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end
    
    % Do the estimation
    %------------------------------------------------------
    if options.recursive_estim

        error([mfilename ':: Recursive estimation is not yet supported for estimation of DSGE models solved using RISE.'])

    %======================
    else % Not recursive
    %======================
        
        dataS  = nb_date.date2freq(sDate);
        start  = dataS + (options.estim_start_ind - 1);
        finish = dataS + (options.estim_end_ind - 1);
        
        options.riseObject = estimate(options.riseObject,...
                                'data',             data_ts,...
                                'kf_presample',     options.kf_presample,...
                                'estim_start_date', toString(start),...
                                'estim_end_date',   toString(finish),...
                                'optimizer',        options.optimizer,...
                                'estim_priors',     options.prior,...
                                'kf_init_variance', options.kf_init_variance,...
                                'optimset',         options.optimset);
        
        % Get estimation results
        %--------------------------------------------------
        res         = struct();
        res.beta    = options.riseObject.parameter_values;
        res.stdBeta = options.riseObject.estimation.posterior_maximization.mode_stdev;
        res.sigma   = nan(0,1);
        
        % Convert output to wanted format
        level     = {'smoothed','filtered','updated'};
        goThrough = {'variables','shocks','measurement_errors','regime_probabilities','state_probabilities'};
        regNum    = options.riseObject.markov_chains.regimes_number;
        for ll = 1:length(level)

            for gt = 1:length(goThrough)

                try
                    value = options.riseObject.filtering.([level{ll},'_',goThrough{gt}]);
                    vars  = fieldnames(value)';
                    if gt > 3
                        data = structToDouble(value,1);
                    else
                        data = structToDouble(value,regNum);
                    end
                catch %#ok<CTCH>
                    continue
                end
                res.(level{ll}).(goThrough{gt}) = struct('data',data,'startDate',toString(start),'variables',{vars});

            end

        end
        
    end

    % Assign generic results
    res.includedObservations = nb_dateminus(finish,start);
    res.elapsedTime          = toc(tStart);
    res.filterStartDate      = toString(start);
    res.filterEndDate        = toString(finish);
    
    % Assign results
    results           = res;
    options.estimator = 'nb_risedsgeEstimator';
    options.estimType = 'bayesian';

    % Assign default posterior draws options
    posterior = struct('model',options.riseObject,'betaD',nan(size(res.beta,1),size(res.beta,2),0),...
                       'sigmaD',nan(size(res.sigma,1),size(res.sigma,2),0),'type','RISEDSGE',...
                       'burnin',0,'thin',1,'algorithm','mh_sampler');
    options.pathToSave = nb_saveDraws(options.name,posterior);
    
end

%==========================================================================
function dataT = structToDouble(value,regNum)

    fields = fieldnames(value);
    nvars  = length(fields);
    nobs   = size(double(value.(fields{1})),1);
    dataT  = nan(nobs,nvars,regNum);
    for ii = 1:nvars
       dataT(:,ii,:) = permute(double(value.(fields{ii})),[1,3,2]); 
    end

end

