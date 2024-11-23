function forecastOutput = forecastPerc2Dist(forecastOutput)
% Syntax:
%
% forecastOutput = nb_model_forecast.forecastPerc2Dist(forecastOutput)
%
% Description:
%
% Calculates a density from percentiles using kernel estimation.
% 
% Input:
% 
% - forecastOutput : A forecast property of the nb_model_forecast 
%                    class where the forecastOutput.data stores 
%                    the forecast of the percentiles. 
%
% Output:
%
% - forecastOutput : A struct on the same format as the 
%                    nb_model_forecast.forecastOutput property
%
% See also:
% nb_model_forecast.forecast
%
% Written by Per Bjarne Bye, Kenneth Sæterhagen Paulsen and Atle
% Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    perc    = forecastOutput.perc;
    data    = forecastOutput.data; % nHor x nVars x nPerc + 1 x nRec
    horizon = size(data,1);
    
    if ~((length(perc) + 1) == size(data,3))
        error([mfilename ':: Model need to have been forecasted on quantiles for this to work. To '...
            'trigger the forecast of quantiles you need to set the "draws" option to a number greater than 1.'])
    end

    % Last page of forecastOutput.data is the median/mean/mode observation.
    % Need to shuffle it back into the correct order
    newData   = nan(size(data,1),size(data,2),size(data,3),size(data,4));
    belowMean = [perc < 50,false];
    aboveMean = [perc > 50,false];
    medianInd = sum(belowMean) + 1;

    % First column of data is the dependent variable
    newData(:,:,belowMean,:)       = data(:,:,belowMean,:);
    newData(:,:,medianInd,:)       = data(:,:,end,:);
    newData(:,:,medianInd+1:end,:) = data(:,:,aboveMean,:);
    
    % Do the kernel estimation
    nVars = size(newData,2);
    for ii = 1:size(newData,4)
        
        fcstDensityAll = cell(1,nVars);
        int            = cell(1,nVars);
        for vv = 1:size(newData,2)
        
            fcstDensity = nan(horizon,1000);
            domain      = nan(horizon,1000);
            for hh = 1:horizon
                [fcstDensity(hh,:),domain(hh,:)] = ksdensity(squeeze(newData(hh,vv,:,ii)),'NumPoints',1000);
            end
            fcstDensityAll{vv} = fcstDensity;
            int{vv}            = domain;
            
        end

        % X (domain) : mdl.forecastOutput.forecast.evaluation.int
        % pdf        : mdl.forecastOutput.forecast.evaluation.density
        forecastOutput.evaluation(ii).density = fcstDensityAll;
        forecastOutput.evaluation(ii).int     = int;
    
    end
        
end 
