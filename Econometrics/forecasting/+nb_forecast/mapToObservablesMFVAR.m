function [Y,dep] = mapToObservablesMFVAR(Y,options,model,inputs,start)
% Syntax:
%
% [Y,dep] = nb_forecast.mapToObservablesMFVAR(Y,options,model,inputs,start)
%
% Description:
%
% Get forecast on the observable variables of a MF-VAR and merge with rest.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dep   = nb_forecast.getForecastVariables(options,model,inputs,'notAll');
    YT    = permute(Y,[2,1,3]);
    draws = size(YT,3);
    if size(model.H,4) > 1
        % First we need to get the time-varying measurment equations
        nSteps              = size(Y,1);
        opt                 = options;
        opt.estim_start_ind = start + 1;
        opt.estim_end_ind   = start + nSteps;
        H                   = nb_mlEstimator.getMeasurmentEqMFVAR(opt);
        
        % Predict observed variables given the time-varying measurment 
        % equations
        Yobs = nan(size(H,1),size(YT,2),draws);
        for ii = 1:draws
            for hh = 1:nSteps
                Yobs(:,hh,ii) = H(:,:,hh)*YT(:,hh,ii); 
            end
        end
    else
        % Predict observed variables given the fixed measurement equations
        H    = model.H(:,:,end);
        Yobs = nan(size(H,1),size(YT,2),draws);
        for ii = 1:draws
            Yobs(:,:,ii) = H*YT(:,:,ii); % Get forecast on the observed variables
        end
    end
    Yobs = permute(Yobs,[2,1,3]); % nSteps x nVar x nDraws
    if not(strcmpi(inputs.output,'fullendo') || strcmpi(inputs.output,'full'))
        nDep = length(options.dependent) + length(options.block_exogenous) - sum(options.indObservedOnly);
        Y    = Y(:,1:nDep,:); % Remove lags of state variables
    end
    Y = [Yobs,Y];
    
end
