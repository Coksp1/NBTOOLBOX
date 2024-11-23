function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_harmonizeEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    predicted           = nb_harmonizeEstimator.getPredicted(results,options);
    predicted.variables = strrep(predicted.variables,'Predicted_','');
    residual            = nb_harmonizeEstimator.getDependent(results,options) - predicted;
    residual.variables  = strcat('E_',residual.variables);
    
end
