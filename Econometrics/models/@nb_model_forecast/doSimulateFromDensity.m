function obj = doSimulateFromDensity(obj,draws)
% Syntax:
%
% obj = doSimulateFromDensity(obj,draws)
%
% Description:
%
% Simulates from the estimated kernel density.
% 
% Input:
% 
% - obj   : A nb_model_forecast object.
%
% - draws : Number of draws to use for simulation.
%
% Output:
%
% - obj   : A nb_model_forecast object. See the property forecastOutput.
%  
% See also:
% nb_model_generic.forecast, nb_model_forecast.simulateFromDensity
%
% Written by Per Bjarne Bye and Atle Loneland

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error('The input obj must be a scalar nb_model_forecast object.')
    end
    if nargin < 2
        draws = 1000;
    end
    obj.forecastOutput = nb_model_forecast.simulateFromDensity(obj.forecastOutput,draws);
    
end
