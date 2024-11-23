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

            case {'ols','quantile','lasso','ridge'}

                % Get estimation options
                %-----------------------
                tempOpt      = nb_olsEstimator.template();
                tempOpt.name = obj.name;
                options      = obj.options;

                % Model settings
                exo     = obj.exogenous.name;
                endo    = obj.endogenous.name;
                if ~isempty(endo)
                    exo = [exo,endo];
                end
                if ~isscalar(options.nLags)
                    nlags         = options.nLags;
                    nlags         = [nlags,zeros(1,size(endo,2))];
                    tempOpt.nLags = nlags;
                else
                    tempOpt.nLags = options.nLags;
                end
                tempOpt.addLags = true;
                
                if not(nb_iswholenumber(options.nStep) && isscalar(options.nStep))
                    error('The options.nStep option must be an intger greater than 0.')
                end
                if options.nStep < 1
                    error('The options.nStep option must be an intger greater than 0.')
                end

                tempOpt.dependent = obj.dependent.name;
                tempOpt.exogenous = exo;
                
                % Get options from options property
                fields = setdiff(fieldnames(obj.options),{'data','page','dependent','exogenous',...
                            'estim_end_date','estim_start_date','recursive_estim_start_date','nLags'});
                for ii = 1:length(fields)
                    tempOpt.(fields{ii}) = obj.options.(fields{ii});
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
                if ~isa(dataObj,'nb_ts')
                    error('The nb_sa model must be estimated on time-series models.')
                end
                tempOpt.dataStartDate = toString(dataObj.startDate);
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
                tempOpt.dataVariables = dataObj.variables;
                
                if strcmpi(estim_method,'quantile')
                    tempOpt.quantile = unique([0.5,options.quantile(:)']); % Allways include median regression as things depends on this later on.
                end
                
            otherwise

                error(['The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_sa';
        outOpt               = {tempOpt};
        
    end

end
