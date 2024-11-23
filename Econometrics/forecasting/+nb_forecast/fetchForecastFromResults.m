function fcst = fetchForecastFromResults(results,options,startInd,endInd,nSteps,inputs)
% Syntax:
%
% fcst = nb_forecast.fetchForecastFromResults(results,options,startInd,...
%           endInd,nSteps,inputs)
%
% Description:
%
% The forecast from the model is already produced during the estimation
% step, so we just grab these results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'start')
        error(['The results input must have a field start if the model ',...
            'did produce forecast during the estimation step'])
    end
    if ~isfield(results,'forecasted')
        error(['The results input must have a field forecasted if the model ',...
            'did produce forecast during the estimation step'])
    end
    dep          = results.forecasted;
    forecastData = results.forecast;
    startFcst    = results.start;
    
    % Check 
    if ~isnumeric(forecastData)
        error('The forecast field of the results input must contain a double matrix.')
    end
    if size(forecastData,1) < nSteps
        error(['The forecast field of the results input does not produce a ',...
            int2str(nSteps) ' steap ahead forecast. Only ' int2str(size(forecastData,1))])
    elseif size(forecastData,1) > nSteps
        forecastData = forecastData(1:nSteps,:,:,:);
    end
    if ~(isvector(dep) && iscellstr(dep))
        error('The forecasted field of the results input must be a cellstr vector.')
    end
    dep = nb_rowVector(dep);
    if ~(isvector(startFcst))
        error('The start field of the results input must be a vector.')
    end
    startFcst = nb_rowVector(startFcst);
    if ~nb_iswholerow(startFcst)
        error('The start field of the results input must be a vector of integers.')
    end
    if size(startFcst,2) ~= size(forecastData,4)
        error(['The number of elements of the start field of the results ',...
               'input, must match the size of the forecast along the ',...
               'fourth dimension.'])
    end
    if size(dep,2) ~= size(forecastData,2)
        error(['The number of elements of the forecasted field of the results ',...
               'input, must match the size of the forecast along the second ',...
               'dimension.'])
    end
    draws = size(forecastData,3) - 1;
    if draws == 0
        draws = 1;
    end
    if ~isempty(inputs.fcstEval)
        error(['The fcstEval input is ignored when forecast is fetched ',...
            'from estimation results. Evaluate the model using the ',...
            'evaluateForecast method.'])
    end
    
    % Filter by forecast window
    if isempty(startInd)
        startInd = startFcst(1);
    end
    if isempty(endInd)
        endInd = startFcst(end);
    end
    if startInd > startFcst(1) || endInd < startFcst(end)
        indS         = find(startInd <= startFcst,1);
        indE         = find(endInd <= startFcst,1);
        startFcst    = startFcst(indS:indE);
        forecastData = forecastData(:,:,:,indS:indE);
    end
    
    % Create reported variables
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            nSim            = size(forecastData,3) - 1; % Mean at the end must be removed!
            nSteps          = size(forecastData,1);
            nDep            = size(forecastData,2);
            nIter           = size(forecastData,4);
            nRep            = size(inputs.reporting,1);
            forecastDataRep = nan(nSteps,nDep + nRep,nSim + 1,nIter);
            if nSim == 0
                nSim = 1;
            end
            for ii = 1:size(forecastData,4)
                start = startFcst(ii) - 1;
                [forecastDataRep(:,:,1:nSim,ii),depRep] = nb_forecast.createReportedVariables(options,inputs,forecastData(:,:,1:nSim,ii),dep,start,ii);
            end
            if nSim > 1
                % Calculate mean and append
                forecastDataRep(:,:,nSim+1,:) = mean(forecastDataRep(:,:,1:nSim,:),3);
            end
            dep          = depRep;
            forecastData = forecastDataRep;
        end
    end
        
    % Construct needed output struct
    fcst = struct(...
        'data',           forecastData,...
        'variables',      {dep},...
        'dependent',      {dep},...
        'nSteps',         nSteps,...
        'type',           'provided',...
        'start',          startFcst,...
        'nowcast',        0,...
        'missing',        [],...
        'evaluation',     struct(),...
        'method',         'manual',...
        'draws',          draws,...
        'parameterDraws', 1,...
        'regimeDraws',    1,...
        'perc',           [],...
        'inputs',         inputs,...
        'saveToFile',     false);
    
end
