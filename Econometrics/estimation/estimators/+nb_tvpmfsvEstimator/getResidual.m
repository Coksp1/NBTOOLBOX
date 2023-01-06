function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_tvpmfsvEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object. This is the
% idiosyncatic component of the measurement error, and not the residual
% of the transition equation.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'Z')
        residual = nb_ts();
    else      
        residual = nb_ts(results.smoothed.shocks.data(:,:,end), 'Residual', ...
            results.smoothed.shocks.startDate,results.smoothed.shocks.variables,false); 
    end

end
