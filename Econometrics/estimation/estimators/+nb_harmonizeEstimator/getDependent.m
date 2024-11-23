function dependent = getDependent(~,options)
% Syntax:
%
% dependent = nb_harmonizeEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    y = nb_harmonizeEstimator.getData(options);
    if isempty(options.estim_start_ind)
        start = nb_date.date2freq(options.dataStartDate);
    else
        start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    end
    dependent = nb_ts(y, 'Dependent', start, options.dependent);      

end
