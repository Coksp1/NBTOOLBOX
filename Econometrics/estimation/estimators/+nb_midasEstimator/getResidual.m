function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_midasEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dep = options.dependent;
    if ~isfield(results,'residual')
        residual = nb_ts();
    else
        start    = options.estim_start_date_low;
        vars     = strcat('E_',dep);
        residual = nb_ts(results.residual, 'Residuals', start, vars); 
    end

end
