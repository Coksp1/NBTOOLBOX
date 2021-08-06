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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only handle scalar object.'])
    end
    vars = obj.forecastOutput.variables;

end
