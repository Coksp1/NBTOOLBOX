function [Y,dep] = getEvaluatedVariables(Y,dep,model,inputs)
% Syntax:
%
% [Y,dep] = nb_forecast.getEvaluatedVariables(Y,actual,dep,model,inputs)
%
% Description:
%
% Get evaluated variables and forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        if strcmpi(model.class,'nb_favar') || strcmpi(model.class,'nb_fmdyn')
            vars = [vars,inputs.observables];
        end
        [ind,indV] = ismember(vars,dep);
        indV       = indV(ind);
        Y          = Y(:,indV);
        dep        = dep(indV);
    end
    
    remove = nb_forecast.removeBeforeEvaluated(model,inputs);
    if isempty(remove)
        indK = true(1,length(dep));
    else
        indK = ~ismember(dep,remove);
    end
    dep = dep(indK);
    Y   = Y(:,indK);
    
end
