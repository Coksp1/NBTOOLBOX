function dependent = getDependent(results,options)
% Syntax:
%
% dependent = nb_midasEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    dep = options.dependent;
    dep = nb_cellstrlead(dep,options.nStep);
    if ~isfield(results,'predicted')
        dependent = nb_ts();
    else
        start     = options.estim_start_date_low;
        dependent = nb_ts(results.predicted + results.residual, 'Dependent', start, dep); 
    end

end
