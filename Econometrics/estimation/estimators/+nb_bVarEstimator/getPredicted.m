function predicted = getPredicted(results,options)
% Syntax:
%
% residual = nb_bVarEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dep  = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    
    if ~isfield(results,'predicted')
        predicted = nb_ts();
    else

        if options.recursive_estim
            error([mfilename ':: It is not possible to get the predicted dependent variables when the model is estimated recursivly.'])
        end
        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        vars      = strcat('Predicted_',dep);
        predicted = nb_ts(results.predicted, 'Predicted', start, vars); 


    end

end
