function [dep,Y] = doMeasurementEq(options,results,inputs,nSteps,model,Y,X,dep,iter)
% Syntax:
%
% [dep,Y] = nb_forecast.doMeasurementEq(options,results,inputs,nSteps,...
%               model,Y,X,dep,iter)
%
% Description:
%
% Produce forecast of measurment equation of a factor model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    mSteps = size(Y,2) - nSteps;
    if strcmpi(model.class,'nb_arima')
        Y = Y(1:size(dep,2),2:end);
        return
    elseif strcmpi(model.class,'nb_mfvar') || strcmpi(model.class,'nb_var')
        if options.time_trend
            error('Time-trend is not supported for models estimated with the ''tvpmfsv'' estimator.')
        end
    end
    
    % Shrink to the observables of interest
    [~,ind] = ismember(inputs.observables,model.observables);
    F       = model.F(ind,:,iter);
    G       = model.G(ind,:,iter);
    if strcmpi(model.class,'nb_fmdyn') || strcmpi(model.class,'nb_mfvar') || strcmpi(model.class,'nb_var')
        
        Z = G*Y(:,mSteps + 1:end); % Observation equation
        if ~isempty(model.S)
            % We have done standardization of the data, so scale
            % back again. Allways empty for nb_mfvar and nb_var case
            Z = bsxfun(@times,Z,model.S(ind,:,iter));
        end
        Z    = F*X + Z; % Add contribution of exogenous variables
        nDep = size(dep,2);
        
        % Set the missing observation to smoothed estimate.
        if options.recursive_estim
            tRec = options.recursive_estim_start_ind + iter - options.estim_start_ind;
        else
            tRec = options.estim_end_ind - options.estim_start_ind + 1;
        end
        if strcmpi(model.class,'nb_mfvar') || strcmpi(model.class,'nb_var')
            [~,ind] = ismember(inputs.observables,results.smoothed.variables.variables);
            ZHist   = results.smoothed.variables.data(tRec-mSteps+1:tRec,ind,iter)';
        else
            ZHist = results.smoothed.observables.data(tRec-mSteps+1:tRec,ind,iter)';
        end
        Z = [ZHist,Z];
        
    else % nb_favar
        nDep = size(G,2);
        Z    = G*Y(1:nDep,mSteps + 1:end); % Observation equation
        Z    = F*X + Z; % Add contribution of exogenous variables
        Z    = [nan(size(Z,1),1),Z]; % nb_favar does not support missing observations, so just set ZHist to nan
    end
    
    % Remove unwanted state variables and concatenate
    if strcmpi(model.class,'nb_var')
        % In this case we only return the variables from the measurment
        % equation
        Y = Z;
    else  
        Y   = Y(1:nDep,:);
        Y   = [Y;Z];
        dep = [dep,inputs.observables];
    end

end
