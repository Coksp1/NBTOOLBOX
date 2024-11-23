function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

            case {'expr'}

                % Get estimation options
                %-----------------------
                func         = str2func(['nb_' lower(estim_method) 'Estimator.template']);
                tempOpt      = func();
                tempOpt.name = obj.name;
                options      = obj.options;

                % Model settings
                tempOpt.dependent = obj.dependent.name;
                tempOpt.exogenous = obj.exogenous.name;
                
                % Get options from options property
                fields = setdiff(fieldnames(options),{'data','page','dependent','exogenous',...
                            'estim_end_date','estim_start_date','recursive_estim_start_date'});
                for ii = 1:length(fields)
                    tempOpt.(fields{ii}) = options.(fields{ii});
                end
                
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
                    tempOpt.rollingWindow   = options.rollingWindow;
                else
                    error([mfilename ':: The data option must be set to a nb_ts object.'])
                end
                tempOpt.dataVariables = dataObj.variables; 
                
            otherwise
                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])
        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_exprModel';
        outOpt               = {tempOpt};
        
    end

end
