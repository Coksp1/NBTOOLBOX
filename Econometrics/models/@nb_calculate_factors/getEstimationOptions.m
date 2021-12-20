function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen       

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
           
        tempOpt = obj.options;
        if ~any(strcmpi(tempOpt.estim_method,{'pca','whiten'}))
            error([mfilename ':: The estimation method ' estim_method ' is not supported.'])
        end
        
        % Get estimation options
        tempOpt.name = obj.name; 

        % Model settings
        tempOpt.observables = obj.observables.name;

        % Data, dates, variables and types
        dataObj = tempOpt.data;
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
        tempOpt.dataVariables = dataObj.variables;
        if ~isempty(tempOpt.estim_end_date)
            tempOpt.estim_end_ind = (nb_date.toDate(tempOpt.estim_end_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.estim_end_ind = [];
        end
        if ~isempty(tempOpt.estim_start_date)
            tempOpt.estim_start_ind = (nb_date.toDate(tempOpt.estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.estim_start_ind = [];
        end
        if ~isempty(tempOpt.recursive_estim_start_date)
            tempOpt.recursive_estim_start_ind = (nb_date.toDate(tempOpt.recursive_estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
        else
            tempOpt.recursive_estim_start_ind = [];
        end
        tempOpt.requiredDegreeOfFreedom = 3;
        tempOpt = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.class        = class(obj);
        outOpt               = {tempOpt};
        
    end
    
end
