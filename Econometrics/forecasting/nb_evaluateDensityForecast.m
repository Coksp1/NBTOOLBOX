function fcstEval = nb_evaluateDensityForecast(type,data,forecastData,meanForecastData,inputs)
% Syntax:
%
% fcstEval = nb_evaluateDensityForecast(type,data,...
%                           forecastData,meanForecastData,inputs)
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
%                       - 'logscore'       : Log score 
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
% - inputs           : A struct with the following fields (You don't need
%                      to provide this input):
%
%                      > 'bins'       : See the 'bins' option of the
%                                       uncondForecast method of the
%                                       nb_model_generic class.
%
%                      > 'estDensity' : See the 'estDensity' option of the
%                                       uncondForecast method of the
%                                       nb_model_generic class.
%
% Output:
%
% - fcstEval : A Struct with the following properties:
% 
%               > <type>  : The evaluation score. As a nHor x nvar 
%                           double.
%
%               > density : A 1 x nVar cell. Each element consist of 
%                           nHor x nPoints. For each variable the   
%                           values of the density at the given points 
%                           is stored.
%
%               > int     : A 1 x nVar cell. Each element consist of  
%                           nHor x nPoints. For each variable the 
%                           points where the density is evaluated is 
%                           stored. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        inputs = struct('bins',[],'estDensity','kernel');
        if nargin < 4
            meanForecastData = [];
        end
    end
    
    if isempty(inputs)
        inputs = struct('bins',[],'estDensity','kernel');
    end
    
    if ischar(type) && ~isempty(type)
        type = cellstr(type);
    end
    
    if isempty(meanForecastData)
        meanForecastData = mean(forecastData,3);
    end
    
    [nHor,nVar,~] = size(forecastData);
    
    % Get domain and density
    int = nb_getDensityPoints(forecastData,inputs.bins);
    if strcmpi(inputs.estDensity,'kernel')
        density = nb_estimateKernelDensity(forecastData,int);
        dist    = [];
    else
        
        dist(nHor,nVar) = nb_distribution;
        for hh = 1:nHor
            for ii = 1:nVar
                try
                    dist(hh,ii) = nb_distribution.mme(squeeze(forecastData(hh,ii,:)),inputs.estDensity);
                catch Err
                    fcstData = squeeze(forecastData(hh,ii,:));
                    if all(abs(fcstData(1) - fcstData) < eps)
                        dist(hh,ii) = nb_distribution('type','constant','parameters',{fcstData(1)});
                    else
                        nb_error(['Could not estimate density of type ' inputs.estDensity ...
                            ' for the variable ' int2str(ii) ' at horizon ' int2str(hh) '.'],Err)
                    end
                end
            end
        end

        density = cell(1,nVar);
        for ii = 1:nVar
            dens = cell(nHor,1);
            for hh = 1:nHor
                dens{hh} = {dist(hh,ii).type,dist(hh,ii).parameters};
            end
            density{ii} = dens;
        end
        
    end
    
    % Do the density evaluation
    fcstEval = nb_evaluateDensity(type,data,density,int,meanForecastData,forecastData,dist);
    
end
              
