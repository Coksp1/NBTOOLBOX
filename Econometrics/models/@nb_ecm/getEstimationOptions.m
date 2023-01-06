function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    
        tempOpt      = obj.options;
        estim_method = obj.options.estim_method;
        switch lower(estim_method)

            case 'ols'

                default = nb_ecmEstimator.template();
                tempOpt = nb_structcat(tempOpt,default,'first');
                
                % Get estimation options
                %-----------------------
                tempOpt.name = obj.name;
                options      = obj.options;

                % Model settings
                if ~isempty(tempOpt.nLags)
                    if ~(isnumeric(tempOpt.nLags) || iscell(tempOpt.nLags))
                        error([mfilename ':: The nLags input must be a numeric or cell vector.'])
                    end
                    if ~isscalar(tempOpt.nLags)
                        if length(tempOpt.nLags) ~= obj.dependent.number + obj.endogenous.number
                            error([mfilename ':: If the nLags input is not scalar it has to have length equal to '...
                                   int2str(obj.dependent.number + obj.endogenous.number) ', i.e. the number of dependent ',...
                                   'plus endogenous variables of the model.'])
                        end
                    end
                end
                tempOpt.dependent  = obj.dependent.name;
                tempOpt.endogenous = obj.endogenous.name;
                tempOpt.exogenous  = obj.exogenous.name;

                % Data, dates, variables and types
                dataObj = options.data;
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
                tempOpt               = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});

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
