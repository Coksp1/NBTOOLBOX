function obj = doForecastPerc2Dist(obj)
% Syntax:
%
% obj = doForecastPerc2Dist(obj,draws)
%
% Description:
%
% Calculates a density from percentiles using kernel estimation.
% 
% Input:
% 
% - obj : A nb_model_forecast object. 
% 
%
% Output:
%
% - obj : A nb_model_forecast object. See the property forecastOutput.
%  
% See also:
% nb_model_forecast.forecast, nb_model_forecast.forecastPerc2Dist
%
% Written by Per Bjarne Bye, Kenneth Sæterhagen Paulsen and Atle Loneland

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~obj.isforecasted
       error([mfilename ':: Model must be forecasted before calculating distribution.']) 
    end    
    if isempty(obj.forecastOutput.perc)
       error([mfilename ':: Percentiles must be specified for this to work']) 
    end
    if ~((length(obj.forecastOutput.perc) + 1) == size(obj.forecastOutput.data,3))
        error([mfilename ':: Model need to have been forecasted on quantiles for this to work. To '...
            'trigger the forecast of quantiles you need to set the "draws" option to a number greater than 1.'])
    end

    obj.forecastOutput = nb_model_forecast.forecastPerc2Dist(obj.forecastOutput);
            
end 
