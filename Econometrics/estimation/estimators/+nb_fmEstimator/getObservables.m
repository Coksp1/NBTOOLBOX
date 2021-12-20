function observables = getObservables(results,options)
% Syntax:
%
% observables = nb_fmEstimator.getObservables(results,options)
%
% Description:
%
% Get the observables of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'predicted')
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
        if isfield(options,'observablesFast')
            observables = [observables, options.observablesFast];
        end
        [~,indZ] = ismember(observables,options.dataVariables);
        Z        = options.data(startInd:endInd,indZ); 
        
        observables = nb_ts(Z, 'Dependent', start, observables); 

    end

end
