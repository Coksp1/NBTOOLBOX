function inputs = cleanUpInputs(inputs)
% Syntax:
%
% inputs = nb_forecast.cleanUpInputs(inputs)
%
% Description:
%
% Clean up inputs so it may be given back to nb_model_generic.forecast
% when object i being updated.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    inputs  = nb_rmfield(inputs,{'nObj','index','startInd','endInd','nPeriods','missing',...
                                 'reporting','shift','shiftVariables','waitbar'});

    
end
