function score = nb_evaluateDensityForecastOnlyScore(type,data,forecastData,meanForecastData)
% Syntax:
%
% score = nb_evaluateDensityForecastOnlyScore(type,data,forecastData,...
%                           meanForecastData)
%
% Description:
%
% Evaluate density forecast given a simulated density and mean forecast.
% 
% Input:
%
% - type             : Type of evaluation (Could be a cellstr with more
%                      of these):
%
%                       - 'se'             : Square error
%                       - 'abs'            : Absolute error
%                       - 'diff'           : Forecast error
%                       - 'logscore'       : Log score (Based on a normal
%                                            distribution)
% 
% - data             : The true data to be evaluated against. As a nobs x  
%                      nvar double.
% 
% - forecastData     : A double with size nobs x nvar x nsim with the 
%                      density forecast.
%
% - meanForecastData : A double with size nobs x nvar with the mean 
%                      forecast. If empty it will be calculated.
%
% Output:
%
% - fcstEval : The evaluation score. As a nHor x nvar double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        meanForecastData = [];
    end
    
    if isempty(meanForecastData)
        meanForecastData = mean(forecastData,3);
    end
    
    % Get domain and density
    if isempty(type)
        type = 'se';
    end
    
    % Then evaluate the forecast
    switch lower(type)
        case 'se'
            score   = (data - meanForecastData).^2;
        case 'abs'
            score   = abs(data - meanForecastData);
        case 'diff'
            score   = data - meanForecastData;
        case 'logscore'
            meanF         = mean(forecastData,3);
            stdF          = std(forecastData,1,3);   
            densityNormal = @(x) normpdf(x, meanF, stdF);
            score         = log(densityNormal(data));   
        otherwise
            error([mfilename ':: Unsupported forecast evaluation ' type '.'])
    end
    
end
