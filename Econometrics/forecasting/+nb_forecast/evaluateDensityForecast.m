function [fData,evalFcst] = evaluateDensityForecast(Y,actual,dep,model,options,inputs)
% Syntax:
%
% [fData,evalFcst] = nb_forecast.evaluateDensityForecast(Y,actual,dep,...
%                       model,options,inputs)
%
% Description:
%
% Evalaute density forecasts.
%
% See also:
% nb_forecast.densityForecast, nb_forecast.exprModelDensityForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the mean forecast
    if strcmpi(options(end).estim_method,'quantile')
        YMean = Y(:,:,end);
        Y     = Y(:,:,1:end-1);
    else
        YMean = mean(Y,3);
    end
    
    % Evaluate density forecast
    fcstEval = inputs.fcstEval;

    % Calculate forecast evaluation (if fcstEval is empty only the density
    % is calculated)
    remove = nb_forecast.removeBeforeEvaluated(model,inputs);
    if isempty(remove)
        indK = true(1,length(dep));
    else
        indK = ~ismember(dep,remove);
    end
    if inputs.estimateDensities
        evalFcst = nb_evaluateDensityForecast(fcstEval,actual,Y(:,indK,:),YMean(:,indK,:),inputs);
    else
        evalFcst = nb_evaluateDensity(fcstEval,actual,[],[],YMean(:,indK,:),Y(:,indK,:));
    end
    
    % Get the percentiles
    %.....................
    perc       = inputs.perc;
    [s1,s2,s3] = size(Y);
    if isempty(perc)
        fData              = nan(s1,s2,s3+1);
        fData(:,:,1:end-1) = Y;
        fData(:,:,end)     = YMean;
    else
        nPerc = size(perc,2);
        fData = nan(s1,s2,nPerc+1);
        for ii = 1:nPerc
            fData(:,:,ii) = prctile(Y,perc(ii),3);
        end
        fData(:,:,end) = YMean;
    end

end
