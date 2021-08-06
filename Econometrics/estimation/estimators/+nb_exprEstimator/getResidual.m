function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_exprEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dep = options.dependentOrig;
    if ~isfield(results,'residual')
        residual = nb_ts();
    else
        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (startInd - 1);
        end
        vars     = strcat('E_',dep);
        residual = nb_ts(results.residual, 'Residuals', start, vars); 
    end

end
