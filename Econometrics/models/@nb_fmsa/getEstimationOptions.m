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
           
        tempOpt      = obj.options;
        estim_method = tempOpt.estim_method;
        switch lower(estim_method)

            case {'fm'}

                % Get estimation options
                %-----------------------
                tempOpt.name = obj.name; 

                % Model settings
                exo  = obj.exogenous.name;
                endo = obj.endogenous.name;
                if ~isempty(endo)
                    exo = [exo,endo]; 
                end
                
                if strcmpi(tempOpt.modelSelection,'autometrics')
                    error([mfilename ':: Unsupported model selection option autometrics for a nb_fmsa model'])
                end

                tempOpt.dependent   = obj.dependent.name;
                tempOpt.observables = obj.observables.name;
                tempOpt.exogenous   = exo;
                if ~isempty(tempOpt.nLags)
                    if ~isscalar(tempOpt.nLags)
                        error([mfilename ':: The nLags input must be a scalar.'])
                    end
                end
                
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
                tempOpt.modelType               = 'stepAhead';
                tempOpt = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});
                  
            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_fmsa';
        outOpt               = {tempOpt};
        
    end
    
end
