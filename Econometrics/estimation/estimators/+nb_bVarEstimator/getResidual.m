function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_bVarEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dep = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    
    if ~isfield(results,'residual')
        residual = nb_ts();
    else

        if options.recursive_estim
            error([mfilename ':: It is not possible to get the residuals when the model is estimated recursivly.'])
        end
        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        vars     = strcat('E_',dep);
        residual = nb_ts(results.residual, 'Residuals', start, vars); 

    end

end
