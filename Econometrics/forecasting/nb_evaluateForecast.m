function score = nb_evaluateForecast(type,data,forecastData)
% Syntax:
%
% score = nb_evaluateForecast(type,data,forecastData)
%
% Description:
%
% Evaluate 
% 
% Input:
%
% - type         : Type of evaluation:
%
%                  - 'se'   : Square errors
%                  - 'abs'  : Absolute error
%                  - 'diff' : Forecast error
% 
% - data         : The true data to be evaluated against. As a nobs x nvar 
%                  double.
% 
% - forecastData : A double with size nobs x nvar.
%
% Output:
% 
% - score        : The evaluation score. As a nSteps x nvar double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Then evaluate the forecast
    switch lower(type)
        case 'se'
            score = (data - forecastData).^2;
        case 'abs'
            score = abs(data - forecastData);
        case 'diff'
            score = data - forecastData;
        otherwise
            error([mfilename ':: Unsupported forecast evaluation ' type '.'])
    end

end
