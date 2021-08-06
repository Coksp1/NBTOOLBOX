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

            case {'ols','bvar','ml'}

                % Get estimation options
                %-----------------------
                tempOpt.name = obj.name; 

                % Model settings
                exo  = obj.exogenous.name;
                endo = obj.endogenous.name;
                if ~isempty(endo)
                    exo = [exo,endo]; 
                end
                if ~isempty(tempOpt.nLags)
                    if ~isscalar(tempOpt.nLags)
                        error([mfilename ':: The nLags option must be a scalar for the nb_var object.'])
                    end
                end
                
                if strcmpi(tempOpt.modelSelection,'autometrics')
                    error([mfilename ':: Unsupported model selection option autometrics for a nb_var model'])
                end

                tempOpt.dependent           = obj.dependent.name;
                tempOpt.block_exogenous     = obj.block_exogenous.name;
                tempOpt.block_id            = obj.block_exogenous.block_id;
                tempOpt.factors             = obj.factors.name;
                if ~isempty(tempOpt.factors)
                    error([mfilename ':: The factors property is not yet supported.'])
                end
                tempOpt.exogenous           = exo;
                tempOpt.modelSelectionFixed = true(1,length(exo));
                
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
                tempOpt.dataVariables  = dataObj.variables;
                tempOpt.estim_types    = {};
                tempOpt                = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});
                
                if ~isempty(tempOpt.prior) 
                    if tempOpt.recursive_estim || tempOpt.real_time_estim
                        if any(strcmpi(tempOpt.prior.type,nb_var.mfPriors()))
                            % Trigger nb_missingEstimator when dealing with
                            % missing observation B-VAR models.
                            tempOpt.missingMethod = 'kalman';
                        end
                    end
                end
                
            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_var';
        outOpt               = {tempOpt};
        
    end
    
end
