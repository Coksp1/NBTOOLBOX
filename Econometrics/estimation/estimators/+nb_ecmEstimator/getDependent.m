function dependent = getDependent(results,options)
% Syntax:
%
% dependent = nb_ecmEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    dep  = options.dependent;
    if ~isfield(results,'predicted')
        dependent = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        dependent = nb_ts(results.predicted + results.residual(:,1), 'Dependent', start, dep); 

    end

end
