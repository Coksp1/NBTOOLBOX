function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_fmEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'predicted')
        predicted = nb_ts();
    else

        if strcmpi(options.modelType,'favar')
            dep  = [options.dependent,options.factors];
            pred = results.predicted; 
        elseif strcmpi(options.modelType,'dynamic')
            dep  = [options.dependent,options.factors];
            pred = [results.predicted{:}];
        elseif strcmpi(options.modelType,'stepAhead')
            dep   = nb_cellstrlead(options.dependent,options.nStep);
            pred  = results.predicted;
        else
            dep  = options.dependent;
            pred = results.predicted;
        end
        
        endInd    = options.estim_end_ind;
        start     = nb_date.date2freq(options.dataStartDate) + (endInd - size(pred,1) + 1);
        vars      = strcat('Predicted_',dep);
        predicted = nb_ts(pred, 'Predicted', start, vars); 

    end

end
