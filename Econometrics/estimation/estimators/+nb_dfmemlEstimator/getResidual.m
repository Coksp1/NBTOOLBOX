function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_dfmemlEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object. This is the
% idiosyncatic component of the measurment error, and not the residual
% of the transition equation.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'Z')
        residual = nb_ts();
    else      
        predicted   = nb_dfmemlEstimator.getPredicted(results,options);
        predicted   = rename(predicted,'variables','Predicted_*','');
        observables = nb_dfmemlEstimator.getObservables(results,options);
        residual    = observables - predicted;
    end

end
