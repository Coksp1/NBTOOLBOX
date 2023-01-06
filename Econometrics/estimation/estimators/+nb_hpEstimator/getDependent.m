function dependent = getDependent(results,options)
% Syntax:
%
% dependent = nb_hpEstimator.getDependent(results,options)
%
% Description:
%
% Get the dependent variables of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        dependent = nb_ts();
    else

        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        
        dependent = [options.dependent];
        [~,indZ]  = ismember(dependent,options.dataVariables);
        Z         = options.data(startInd:endInd,indZ);   
        dependent = nb_ts(Z, 'Dependent', start, dependent); 

    end

end
