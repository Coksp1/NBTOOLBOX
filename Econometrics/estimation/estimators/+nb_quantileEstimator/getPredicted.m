function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_quantileEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    isTS = isempty(options.estim_types);
    dep  = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    
    if ~isfield(results,'predicted')
        predicted = nb_ts();
    else

        indQ = options.quantile == 0.5;
        if isTS

            startInd = options.estim_start_ind;
            if isempty(startInd)
                start = nb_date.date2freq(options.dataStartDate);
            else
                start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
            end
            vars      = strcat('Predicted_',dep);
            predicted = nb_ts(results.predicted(:,:,:,indQ), 'Predicted', start, vars);

        else % nb_cs

            types = options.estim_types;
            if isempty(types)
                typesT = options.dataTypes;
            else
                typesT = types;
            end
            vars      = strcat('Predicted_',dep);
            predicted = nb_cs(results.predicted(:,:,:,indQ), 'Predicted', typesT, vars); 
            
        end

    end

end
