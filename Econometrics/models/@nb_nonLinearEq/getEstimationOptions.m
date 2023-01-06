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
    
        estim_method = obj.options.estim_method;
        switch lower(estim_method)

            case {'nls'}

                % Get estimation options
                %-----------------------
                tempOpt      = obj.options;
                tempOpt.name = obj.name;

                % Data, dates, variables and types
                dataObj = obj.options.data;
                if ~obj.options.real_time_estim
                   if dataObj.numberOfDatasets > 1
                       if isempty(obj.options.page)
                           obj.options.page = dataObj.numberOfDatasets;
                       end
                       dataObj = window(dataObj,'','','',obj.options.page);
                   end
                end
                tempOpt.data = dataObj.data;
                if isa(dataObj,'nb_ts')
                    tempOpt.dataStartDate = toString(dataObj.startDate);
                    if ~isempty(obj.options.estim_end_date)
                        tempOpt.estim_end_ind = (nb_date.toDate(obj.options.estim_end_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.estim_end_ind = [];    
                    end
                    if ~isempty(obj.options.estim_start_date)
                        tempOpt.estim_start_ind = (nb_date.toDate(obj.options.estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.estim_start_ind = [];       
                    end
                    if ~isempty(obj.options.recursive_estim_start_date)
                        tempOpt.recursive_estim_start_ind = (nb_date.toDate(obj.options.recursive_estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                    else
                        tempOpt.recursive_estim_start_ind = [];       
                    end
                else
                    tempOpt.dataTypes = dataObj.types;
                end
                tempOpt.dataVariables = dataObj.variables; 
                tempOpt.parser        = obj.estOptions.parser;
                 
            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_nonLinearEq';
        outOpt               = {tempOpt};
        
    end

end
