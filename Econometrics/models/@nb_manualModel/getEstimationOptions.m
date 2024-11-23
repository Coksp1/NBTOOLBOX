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

            case {'manual'}

                % Get estimation options
                %-----------------------
                func         = str2func(['nb_' lower(estim_method) 'Estimator.template']);
                tempOpt      = func();
                tempOpt.name = obj.name;
                options      = obj.options;

                % Get options from options property
                fields = setdiff(fieldnames(options),{'data','page','estim_end_date',...
                    'estim_start_date','recursive_estim_start_date'});
                for ii = 1:length(fields)
                    tempOpt.(fields{ii}) = options.(fields{ii});
                end
                
                % Data, dates, variables and types
                tempOpt = nb_model_estimate.fromDataTS2Options(tempOpt,options);
                tempOpt = nb_model_estimate.fromCondDB2Options(tempOpt,options);
                
            otherwise
                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])
        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_manualModel';
        outOpt               = {tempOpt};
        
    end

end
