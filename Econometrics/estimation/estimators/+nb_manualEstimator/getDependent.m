function dependent = getDependent(~,options)
% Syntax:
%
% residual = nb_manualEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(options,'dependent')
        dependent = nb_ts();
    else
        [~,indY]  = ismember(options.dependent,options.dataVariables);
        sample    = options.estim_start_ind:options.estim_end_ind;
        y         = options.data(sample,indY);
        start     = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        dependent = nb_ts(y, 'Dependent', start, options.dependent); 
    end

end
