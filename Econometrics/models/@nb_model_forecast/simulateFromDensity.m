function forecastOutput = simulateFromDensity(forecastOutput,draws)
% Syntax:
%
% obj = nb_model_forecast.simulateFromDensity(forecastOutput,draws)
%
% Description:
%
% Simulates from the estimated kernel density.
% 
% Input:
% 
% - forecastOutput : A forecast property of the nb_model_forecast 
%                    class where the forecastOutput.evaluation stores 
%                    the kernel density estimate.
%
% - draws          : Number of draws to use for simulation.
%
% Output:
% 
% - forecastOutput : A struct on the same format as the 
%                    nb_model_forecast.forecastOutput property
%  
% See also:
% nb_model_generic.forecast, forecastPerc2Dist
%
% Written by Per Bjarne Bye and Atle Loneland

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        draws = 1000;
    end
    
    % Preallocate double to store simulated forecast + mean
    [nHor,nVars,~,nRec] = size(forecastOutput.data);
    sim                 = zeros(nHor,nVars,draws+1,nRec);
    
    % Do the simulation, and fill in forecast
    eval = forecastOutput.evaluation; % A 1 x nRec struct array
    for ii = 1:size(eval,2)
        Y                   = nb_simulateFromDensity(eval(ii).density,eval(ii).int,draws);
        sim(:,:,1:end-1,ii) = Y;
        sim(:,:,end,ii)     = mean(Y,4);
    end
    
    % Store back to object (remmeber that last page of the 3rd dimension 
    % must be the mean!)
    forecastOutput.data  = sim;
    forecastOutput.draws = draws;
    
    % The object does not longer store percentiles
    forecastOutput.perc = [];
    
end
