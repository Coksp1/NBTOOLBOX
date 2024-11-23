function predicted = getPredicted(results,options)
% Syntax:
%
% residual = nb_manualEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    dep = options.dependent;
    if ~isfield(results,'predicted')
        predicted = nb_ts();
    else

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
