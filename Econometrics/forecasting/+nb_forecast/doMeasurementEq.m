function [dep,Y] = doMeasurementEq(inputs,nSteps,model,Y,X,dep,iter)
% Syntax:
%
% [dep,Y] = nb_forecast.doMeasurementEq(inputs,nSteps,model,Y,dep,iter)
%
% Description:
%
% Produce forecast of measurment equation of a factor model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(model.class,'nb_arima')
        Y = Y(1:size(dep,2),2:end);
        return
    elseif ~strcmpi(model.class,'nb_fmdyn')
        X = ones(1,nSteps); % Only constant is supported in this case
    end
    
    % Shrink to the observables of interest
    [~,ind] = ismember(inputs.observables,model.observables);
    F       = model.F(ind,:,iter);
    G       = model.G(ind,:,iter);
    if strcmpi(model.class,'nb_fmdyn')
        Z = G*Y(:,2:end); % Observation equation
        if ~isempty(model.S)
            % We have done standardization of the data, so scale
            % back again
            Z = bsxfun(@times,Z,model.S(ind,:,iter));
        end
        nDep = size(dep,2);
    else % nb_favar
        nDep = size(G,2);
        Z    = G*Y(1:nDep,2:end); % Observation equation
    end
    Z = F*X + Z; % Add contribution of exogenous variables
    
    % Remove unwanted state variables and concatenate
    Y   = Y(1:nDep,2:end);
    Y   = [Y;Z];
    dep = [dep,inputs.observables];

end
