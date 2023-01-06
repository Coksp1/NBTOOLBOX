function vars = getForecastVariables(obj)
% Syntax:
%
% vars = getForecastVariables(obj)
%
% Description:
%
% Get the variables that the model forecast.
% 
% Input:
% 
% - obj  : An object of class nb_model_forecast.
%
% Output:
% 
% - vars : A cellstr with the variables of the original data source.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only handle scalar object.'])
    end
    vars = obj.forecastOutput.variables;

end
