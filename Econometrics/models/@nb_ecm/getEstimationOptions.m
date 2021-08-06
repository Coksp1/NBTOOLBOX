function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Set up the estimator
    %------------------------------------------------------
    obj  = obj(:);
    nobj = size(obj,1);
    if nobj > 1
        
        outOpt = cell(1,nobj);
        for ii = 1:nobj
            outOpt(ii) = getEstimationOptions(obj(ii));
        end
        
    elseif nobj == 1
    
        estim_method = obj.options.estim_method;
        switch lower(estim_method)

            case 'ols'

                % Get estimation options
                %-----------------------
                tempOpt      = nb_ecmEstimator.template();
                tempOpt.name = obj.name;
                options      = obj.options;

                % Model settings
                if ~isempty(options.nLags)
                
                    if ~(isnumeric(options.nLags) || iscell(options.nLags))
                        error([mfilename ':: The nLags input must be a numeric or cell vector.'])
                    end

                    if ~isscalar(options.nLags)
                        if length(options.nLags) ~= obj.dependent.number + obj.endogenous.number
                            error([mfilename ':: If the nLags input is not scalar it has to have length equal to '...
                                   int2str(obj.dependent.number + obj.endogenous.number) ', i.e. the number of dependent ',...
                                   'plus endogenous variables of the model.'])
                        end
                    end
                    tempOpt.nLags = options.nLags;
                    
                end

                tempOpt.dependent            = obj.dependent.name;
                tempOpt.endogenous           = obj.endogenous.name;
                tempOpt.exogenous            = obj.exogenous.name;
                tempOpt.constant             = options.constant;
                tempOpt.criterion            = options.criterion;
                tempOpt.maxLagLength         = options.maxLagLength;
                tempOpt.modelSelection       = options.modelSelection;
                tempOpt.modelSelectionAlpha  = options.modelSelectionAlpha;
                tempOpt.nLagsTests           = options.nLagsTests;
                tempOpt.stdType              = options.stdType;
                tempOpt.time_trend           = options.time_trend;
                tempOpt.method               = options.method;
                tempOpt.exoLags              = options.exoLags;

                % Data, dates, variables and types
                dataObj      = options.data;
                if ~options.real_time_estim
                   if dataObj.numberOfDatasets > 1
                       if isempty(options.page)
                           options.page = dataObj.numberOfDatasets;
                       end
                       dataObj = window(dataObj,'','','',options.page);
                   end
                end
                tempOpt.data = dataObj.data;
                if isa(dataObj,'nb_ts')
                    tempOpt.dataStartDate             = toString(dataObj.startDate);
                    if ~isempty(options.estim_end_date)
                        tempOpt.estim_end_ind = (nb_date.toDate(options.estim_end_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.estim_end_ind = [];    
                    end
                    if ~isempty(options.estim_start_date)
                        tempOpt.estim_start_ind = (nb_date.toDate(options.estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.estim_start_ind = [];       
                    end
                    if ~isempty(options.recursive_estim_start_date)
                        tempOpt.recursive_estim_start_ind = (nb_date.toDate(options.recursive_estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.recursive_estim_start_ind = [];       
                    end
                    tempOpt.real_time_estim = options.real_time_estim;
                    tempOpt.recursive_estim = options.recursive_estim;
                else
                    error([mfilename ':: The data must be time-series when estimating a ECM model.'])
                end
                tempOpt.dataVariables = dataObj.variables; 

            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = 'ecm';
        tempOpt.class        = 'nb_ecm';
        outOpt               = {tempOpt};
        
    end

end
