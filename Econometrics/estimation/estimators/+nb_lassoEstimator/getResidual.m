function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_lassoEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    isTS = isempty(options.estim_types);
    dep  = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    
    if ~isfield(results,'residual')
        residual = nb_ts();
    else

        if isTS

            startInd = options.estim_start_ind;
            if isempty(startInd)
                start = nb_date.date2freq(options.dataStartDate);
            else
                start = nb_date.date2freq(options.dataStartDate) + (startInd - 1);
            end
            vars     = strcat('E_',dep);
            residual = nb_ts(results.residual, 'Residuals', start, vars); 

        else % nb_cs

            types = options.estim_types;
            if isempty(types)
                typesT = options.dataTypes;
            else
                typesT = types;
            end
            vars     = strcat('E_',dep);
            residual = nb_cs(results.residual, 'Residuals', typesT, vars); 

        end

    end

end
