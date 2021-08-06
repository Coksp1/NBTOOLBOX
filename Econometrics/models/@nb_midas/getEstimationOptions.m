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

            case 'midas'

                % Get estimation options
                %-----------------------
                tempOpt      = obj.options;
                tempOpt.name = obj.name;

                % Model settings
                exo = obj.exogenous.name;
%                 if isscalar(tempOpt.nLags)
%                     nlags         = tempOpt.nLags;
%                     tempOpt.nLags = nlags(:,ones(1,size(exo,2)));
%                 end
                
                if ~nb_isScalarInteger(tempOpt.nStep)
                    error([mfilename 'The options.nStep option must be an intger greater than 0.'])
                end
                if tempOpt.nStep < 1
                    error([mfilename 'The options.nStep option must be an integer greater than 0.'])
                end
                tempOpt.dependent = obj.dependent.name;
                tempOpt.exogenous = exo;
                
                % Data, dates, variables and types
                dataObj = tempOpt.data;
                if ~tempOpt.real_time_estim
                   if dataObj.numberOfDatasets > 1
                       if isempty(tempOpt.page)
                           options.page = dataObj.numberOfDatasets;
                       end
                       dataObj = window(dataObj,'','','',options.page);
                   end
                end
                tempOpt.data = double(dataObj);
                if ~isa(dataObj,'nb_ts')
                    error([mfilename ':: The nb_midas model must be estimated on time-series data.'])
                end
                
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
                tempOpt.dataVariables = dataObj.variables; 

                tempOpt = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});
                
            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_midas';
        outOpt               = {tempOpt};
        
    end

end
