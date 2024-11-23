function options = arMethod(options)
% Syntax:
%
% options = nb_missingEstimator.arMethod(options)
%
% Description:
%
% Fill in for missing observations using AR models.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set up ARIMA models
    finish                = options.estim_end_ind;
    tempOpt               = nb_arimaEstimator.template();
    tempOpt.integration   = nan;
    tempOpt.MA            = 0;
    tempOpt.doTests       = false;
    tempOpt.maxAR         = 10;
    tempOpt.criterion     = 'sic';
    tempOpt.data          = options.data;
    tempOpt.dataVariables = options.dataVariables;
    tempOpt.dataStartDate = options.dataStartDate;

    % Estimate AR model and forecast
    forecastVars = options.missingVariables;
    indRemove    = cellfun(@(x)strfind(x,'_lag'),forecastVars,'UniformOutput',false);
    indRemove    = cellfun(@isempty,indRemove);
    forecastVars = forecastVars(indRemove);
    missing      = options.missingData(1:finish,indRemove);
    for ii = 1:length(forecastVars)
        estEnd = find(~missing(:,ii),1,'last');
        if estEnd ~= finish
            tempOpt.dependent     = forecastVars(ii);
            tempOpt.estim_end_ind = estEnd;
            [results,tempOpt]     = nb_arimaEstimator.estimate(tempOpt);
            model                 = nb_arima.solveNormal(results,tempOpt);
            inputs                = nb_forecast.defaultInputs(true);
            nSteps                = finish - estEnd;
            fcst                  = nb_forecast(model,tempOpt,results,estEnd+1,[],nSteps,inputs,[],{},[]);
            
            % Assign to data property to use for full sample estimation
            indV = strcmpi(fcst.dependent,options.dataVariables);
            options.data(finish-nSteps+1:finish,indV) = fcst.data;
            
        end
    end
    
    % Fill in for lagged variables as well
    lagged               = options.missingVariables(~indRemove);
    nLag                 = regexp(lagged,'[0-9]+$','match');
    nLag                 = char([nLag{:}]');
    nLags                = max(str2num(nLag)); %#ok<ST2NM>
    [~,locFV]            = ismember(forecastVars,options.dataVariables);
    temp                 = options.data(:,locFV);
    last                 = find(~all(isnan(temp),2),1,'last');
    temp                 = nb_mlag(temp,nLags,'varFast');
    temp(last+1:end,:)   = nan;
    tempVars             = nb_cellstrlag(forecastVars,nLags,'varFast');
    [indL,locL]          = ismember(tempVars,options.dataVariables);
    locL                 = locL(indL);
    options.data(:,locL) = temp;

end
