function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen       

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set up the estimators
    %------------------------------------------------------
    obj  = obj(:);
    nobj = size(obj,1);
    if nobj > 1
        
        outOpt = cell(1,nobj);
        for ii = 1:nobj
            outOpt(ii) = getEstimationOptions(obj(ii));
        end
        
    elseif nobj == 1
           
        if isfield(obj.parser,'unitRoot')
            if ~isempty(obj.parser.unitRoot)
                error([mfilename ':: Cannot estimate a model that has specified unit root variables. ',...
                                 'To estimate this model you need to stationarize the model and write ',...
                                 'the resulted model to a new model file. Parse that model and proceed ',...
                                 'with estimation. See nb_dsge.writeModel2File'])
            end
        end
        
        oldParser = obj.parser;
        if obj.options.blockDecompose
            % Decompose the model into main and epilogue. All the
            % equations of the epilogue except the once needed for the
            % observables are just removed from the model, as they don't 
            % affect the likelihood
            obj = blockDecompose(obj,true);
        else
            % Secure that symbolic derivatives are taken if not already
            % found
            obj.options = nb_defaultField(obj.options,'derivativeMethod','automatic');
            if strcmpi(obj.options.derivativeMethod,'symbolic')
                if ~isfield(obj.parser,'derivativeFunc')
                    [obj.parser.derivativeFunc,obj.parser.derivativeInd] = doSymbolicDerivatives(obj);
                end
            end
        end
        
        tempOpt                  = createEstOptionsStruct(obj);
        tempOpt.oldParser        = oldParser;
        tempOpt.estim_end_date   = obj.options.estim_end_date;
        tempOpt.estim_start_date = obj.options.estim_start_date;
        
        % Assign the observables to the parser
        if isNB(obj)
            tempOpt.parser.observables = obj.observables.name;
        end
        
        % Get estimation options
        %-----------------------
        tempOpt.name = obj.name;
        
        % Data, dates, variables and types
        dataObj = obj.options.data;
        if ~tempOpt.real_time_estim
           if dataObj.numberOfDatasets > 1
               if isempty(tempOpt.page)
                   tempOpt.page = dataObj.numberOfDatasets;
               end
               dataObj = window(dataObj,'','','',tempOpt.page);
           end
        end
        tempOpt.data          = dataObj.data;
        tempOpt.dataStartDate = toString(dataObj.startDate);
        if ~isempty(tempOpt.estim_end_date)
            tempOpt.estim_end_date = toString(tempOpt.estim_end_date);
        else
            try tempOpt.estim_end_date = obj.results.filterEndDate; catch; end    %#ok<CTCH>
        end
        if ~isempty(tempOpt.estim_start_date)
            tempOpt.estim_start_date = toString(tempOpt.estim_start_date);
        else
            try tempOpt.estim_start_date = obj.results.filterStartDate; catch; end    %#ok<CTCH>
        end
        if ~isempty(tempOpt.recursive_estim_start_date)
            tempOpt.recursive_estim_start_date = toString(tempOpt.recursive_estim_start_date);
        end
        tempOpt.dataVariables           = dataObj.variables;
        tempOpt.requiredDegreeOfFreedom = 3;
              
        if ~isempty(tempOpt.estim_end_date) && ~isempty(dataObj)
            tempOpt.estim_end_ind = (nb_date.toDate(tempOpt.estim_end_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.estim_end_ind = [];
        end
        if ~isempty(tempOpt.estim_start_date)  && ~isempty(dataObj)
            tempOpt.estim_start_ind = (nb_date.toDate(tempOpt.estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.estim_start_ind = [];
        end
        if ~isempty(tempOpt.recursive_estim_start_date)  && ~isempty(dataObj)
            tempOpt.recursive_estim_start_ind = (nb_date.toDate(tempOpt.recursive_estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.recursive_estim_start_ind = [];
        end
        tempOpt       = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});
        tempOpt.class = 'nb_dsge';
        
        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        if isNB(obj)
            tempOpt.estim_method = 'statespace';
            if nb_isempty(obj.options.prior)
                tempOpt.estimType = 'classic';
            else
                tempOpt.estimType = 'bayesian';
            end
            tempOpt.estimator   = 'nb_statespaceEstimator';
            tempOpt.calibration = obj.results.beta; % Values of all parameters not being estimated.
            if ~tempOpt.estim_steady_state_solve
                if ~isfield(obj.solution,'ss')
                    error([mfilename ':: You must solve for the steady-state of the model before ',...
                                     'estimation, if the option estim_steady_state_solve is set to false.'])
                end
                tempOpt.ss = obj.solution.ss;
            end
        elseif isRise(obj)
            tempOpt.estim_method = 'risedsge';
            tempOpt.estimType    = 'bayesian';
            tempOpt.estimator    = 'nb_risedsgeEstimator';
        else
            tempOpt.estim_method = 'dynare';
            tempOpt.estimType    = 'bayesian';
            tempOpt.estimator    = 'nb_dynareEstimator';
        end
        outOpt = {tempOpt};
    end
    
end
