function dependent = getDependent(results,options)
% Syntax:
%
% residual = nb_bVarEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dep = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    
    if ~isfield(results,'predicted')
        dependent = nb_ts();
    else

        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        tempData  = options.data;
        [~,indY]  = ismember(dep,options.dataVariables);
        y         = tempData(startInd:endInd,indY);
        dependent = nb_ts(y, 'Dependent', start, dep); 

    end

end
