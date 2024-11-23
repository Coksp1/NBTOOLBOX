function dependent = getDependent(results,options)
% Syntax:
%
% dependent = nb_nlsEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts or nb_cs object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    isTS = isempty(options.estim_types);
    dep  = options.parser.dependent;
    if ~isfield(results,'predicted')
        dependent = nb_ts();
    else

        if isTS

            startInd = options.estim_start_ind;
            if isempty(startInd)
                start = nb_date.date2freq(options.dataStartDate);
            else
                start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
            end
            dependent = nb_ts(results.predicted + results.residual, 'Dependent', start, dep); 

        else % nb_cs

            types = options.estim_types;
            if isempty(types)
                typesT = options.dataTypes;
            else
                typesT = types;
            end
            dependent = nb_cs(results.predicted + results.residual, 'Dependent', typesT, dep); 

        end

    end

end
