function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_arimaEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'residual')
        residual = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        vars     = {'E_U'};
        residual = nb_ts(results.residual, 'Residuals', start, vars);  

    end

end
