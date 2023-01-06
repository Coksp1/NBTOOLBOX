function options = getOptionsFromEstOptions(estOptions)
% Syntax:
%
% options = nb_model_estimate.getOptionsFromEstOptions(estOptions)
%
% Description:
%
% Get options from estOptions.
% 
% See also:
% nb_model_estimate.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options = estOptions;
    data    = nb_modelData.getDataAsObject(estOptions);
    
    % Adjust estimation dates
    if isa(data,'nb_ts')
        if isempty(estOptions.estim_start_ind)
            options.estim_start_date = '';
        else
            options.estim_start_date = data.startDate + (estOptions.estim_start_ind - 1);
        end
        if isempty(estOptions.estim_end_ind)
            options.estim_end_date = '';
        else
            options.estim_end_date = data.startDate + (estOptions.estim_end_ind - 1);
        end
        if isempty(estOptions.recursive_estim_start_ind)
            options.recursive_estim_start_date = '';
        else
            options.recursive_estim_start_date = data.startDate + (estOptions.recursive_estim_start_ind - 1);
        end
    end
    options.data = data;
    
    % Delete fields
    if isfield(options,'class')
        classTemplate  = str2func([options.class, '.template']);
        optionsTemp    = classTemplate();
        delOptionNames = setdiff(fieldnames(options),fieldnames(optionsTemp));
    else
        delOptionNames = {'estim_end_ind','estim_start_ind','recursive_estim_start_ind',...
                          'dataStartDate','dataVariables','class','context','name'};
    end
    options = nb_rmfield(options,delOptionNames);

end
