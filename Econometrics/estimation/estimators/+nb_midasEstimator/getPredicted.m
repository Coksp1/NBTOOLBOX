function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_midasEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    dep  = options.dependent;
    dep  = nb_cellstrlead(dep,options.nStep);
    if ~isfield(results,'predicted')
        predicted = nb_ts();
    else
        start     = options.estim_start_date_low;
        vars      = strcat('Predicted_',dep);
        predicted = nb_ts(results.predicted, 'Predicted', start, vars); 
    end

end
