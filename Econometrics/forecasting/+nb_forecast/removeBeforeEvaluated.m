function remove = removeBeforeEvaluated(model,inputs)
% Syntax:
%
% remove = nb_forecast.removeBeforeEvaluated(model,inputs)
%
% Description:
%
% Removed variables from evaluated forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    remove = {};
    if strcmpi(inputs.output,'all') || strcmpi(inputs.output,'full')
        if strcmpi(model.class,'nb_midas')
            remove = [remove,model.res];
        elseif strcmpi(model.class,'nb_arima')
            remove = [remove,model.factors,model.res];
        elseif strcmpi(model.class,'nb_tvp')
            remove = [remove,model.factors,model.res,model.parameters,model.paramRes];
        else
            remove = [remove,model.exo,model.res];
        end
    end
    if nb_isModelMarkovSwitching(model)
        remove = ['states',model.regimes,remove];
    end
    if strcmpi(model.class,'nb_mfvar')
        % For MF-VAR models we cannot evaluate the forecast of the state
        % variables, as these may be on a different frequency
        remove = [model.endo,remove];
    end
    
end
