function options = fillInForMissing(options,check)
% Syntax:
%
% options = nb_missingEstimator.fillInForMissing(options,check)
%
% Description:
%
% Fill in for missing observations.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data = options.missingData(options.missingStartInd:options.missingEndInd,:);
    if any(data(:)) % If missing data

        % If we do recursive estimation we want to pretend that we are in
        % the same information state as in the last period, so we remove 
        % some datapoints
        %
        % If check is false we are inside bootstrapping routine, which means 
        % that this part is already dealt with
        if check
            missing          = options.missingData(1:options.missingEndInd,:);
            missing          = missing(end-options.estim_end_ind+1:end,:); 
            [~,indV]         = ismember(options.missingVariables,options.dataVariables);
            estData          = options.data(1:options.estim_end_ind,indV);
            estData(missing) = nan;

            options.data(1:options.estim_end_ind,indV)     = estData;
            options.data(options.estim_end_ind+1:end,:)    = nan;
            options.missingData(1:options.estim_end_ind,:) = missing;
        end
        
        % Then we fill in for the missing observations
        switch lower(options.missingMethod)        
            case 'forecast'
                options = nb_missingEstimator.forecastMethod(options);
            case 'ar'
                options = nb_missingEstimator.arMethod(options);
            case 'copula'
                options = nb_missingEstimator.copulaMethod(options);
            case 'kalmanfilter'
                options = nb_missingEstimator.kalmanMethod(options);
            case 'kalman'
                % The missing data is filled in for by the estimator itself
        end
        
    end
    
    if check
        options.missingData(options.estim_end_ind+1:end,:) = true;
    end

end
