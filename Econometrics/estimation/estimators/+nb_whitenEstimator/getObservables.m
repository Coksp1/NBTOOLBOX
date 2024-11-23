function observables = getObservables(results,options)
% Syntax:
%
% observables = nb_whitenEstimator.getObservables(results,options)
%
% Description:
%
% Get the observables of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        observables = nb_ts();
    else

        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        
        observables = [options.observables];
        [~,indZ]    = ismember(observables,options.dataVariables);
        Z           = options.data(startInd:endInd,indZ);   
        observables = nb_ts(Z, 'Observables', start, observables); 

    end

end
