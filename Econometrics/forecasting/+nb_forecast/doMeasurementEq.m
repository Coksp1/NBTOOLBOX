function [dep,Y] = doMeasurementEq(options,results,inputs,nSteps,model,Y,X,dep,iter)
% Syntax:
%
% [dep,Y] = nb_forecast.doMeasurementEq(options,results,inputs,nSteps,...
%               model,Y,X,dep,iter)
%
% Description:
%
% Produce forecast of measurement equation of a model with an observation
% equation.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    if any(ind == 0)
        error(['The variables you have provided to the ''observables'' ',...
               'input is not observable variables of the model; ' toString(inputs.observables(ind==0))])
    end
    if ~isempty(model.F)
        F = model.F(ind,:);
    end
    H = model.H(ind,:,:);
    if strcmpi(model.class,'nb_fmdyn') || strcmpi(model.class,'nb_mfvar') || ...
          strcmpi(model.class,'nb_var') 
        
        if size(H,3) > 1
            Z = nan(size(H,1),nSteps);
            for ii = 1:nSteps
                Z(:,ii) = H(:,:,ii)*Y(:,mSteps + ii); % Time-varying observation equation
            end
        else
            Z = H*Y(:,mSteps + 1:end); % Observation equation
        end
        if ~isempty(model.S)
            % We have done standardization of the data, so scale
            % back again. Allways empty for nb_mfvar and nb_var case
            Z = bsxfun(@times,Z,model.S(ind,:));
        end
        if ~isempty(model.F)
            Z = F*X + Z; % Add contribution of exogenous variables
        end
        nDep = size(dep,2);
        
        % Set the missing observation to smoothed estimate.
        if isfield(results,'smoothed')
            dataStart = nb_date.date2freq(options.dataStartDate);
            estStart  = dataStart + (options.estim_start_ind - 1);
            filtStart = nb_date.toDate(results.filterStartDate,dataStart.frequency);
            filtLag   = filtStart - estStart;
            if options.recursive_estim
                tRec = options.recursive_estim_start_ind + iter - options.estim_start_ind - filtLag;
            else
                tRec = options.estim_end_ind - options.estim_start_ind + 1 - filtLag;
            end
            if strcmpi(model.class,'nb_mfvar') || strcmpi(model.class,'nb_var')
                [indO,locO] = ismember(inputs.observables,results.smoothed.variables.variables);
                if ~all(indO)
                    if ~nb_isempty(options.measurementEqRestriction)
                        ZHist     = results.smoothed.variables.data(tRec-mSteps+1:tRec,locO(indO),iter)';
                        tRecRest  = options.estim_end_ind;
                        indRest   = ismember(options.dataVariables,inputs.observables(~indO));
                        ZHistRest = options.data(tRecRest-mSteps+1:tRecRest,indRest)';
                        ZHist     = [ZHist;ZHistRest];
                    else
                       error('This is an issue!') 
                    end
                else
                    ZHist = results.smoothed.variables.data(tRec-mSteps+1:tRec,locO,iter)';
                end
            else
                ZHist = results.smoothed.observables.data(tRec-mSteps+1:tRec,ind,iter)';
            end
            Z = [ZHist,Z];
        else
            Z = [nan(size(Z,1),1),Z];
        end
        
    else % nb_favar
        nDep = size(H,2);
        if size(H,3) > 1
            Z = nan(size(H,1),nSteps);
            for ii = 1:nSteps
                Z(:,ii) = H(:,:,ii)*Y(1:nDep,mSteps + ii); % Time-varying observation equation
            end
        else
            Z = H*Y(1:nDep,mSteps + 1:end); % Observation equation
        end
        Z = F*X + Z; % Add contribution of exogenous variables
        Z = [nan(size(Z,1),1),Z]; % nb_favar does not support missing observations, so just set ZHist to nan
    end
    
    % Remove unwanted state variables and concatenate
    if strcmpi(model.class,'nb_var')
        % In this case we only return the variables from the measurement
        % equation
        Y = Z;
    elseif strcmpi(model.class,'nb_mfvar')
        % In this case we return the variables from the measurement
        % equation first and then the current period state variables
        if isfield(options,'measurementEqRestriction') && ...
                    ~nb_isempty(options.measurementEqRestriction)
            remove = sum(options.indObservedOnly(1:size(options.frequency,2)));
        else
            remove = sum(options.indObservedOnly);
        end
        nDep = length(options.dependent) + length(options.block_exogenous) - remove;
        Y    = Y(1:nDep,:);
        Y    = [Z;Y];
        dep  = nb_forecast.getForecastVariables(options,model,inputs,'notAll');  
    else  
        Y   = Y(1:nDep,:);
        Y   = [Y;Z];
        dep = [dep,inputs.observables];
    end

end
