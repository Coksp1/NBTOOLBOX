function fcstEval = nb_evaluateDensity(type,data,density,int,meanForecastData,forecastData)
% Syntax:
%
% fcstEval = nb_evaluateDensityForecast(type,data,density,domain,...
%                           meanForecastData,forecastData)
%
% Description:
%
% Evaluate density forecast given a density and mean forecast. 
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
% - density          : A 1 x nVars x nPeriods cell. Each element is a double
%                      with size nHor x nDomain.
%
% - int              : A 1 x nVars x nPeriod cell. Each element is a double
%                      with size 1 x nDomain.
%
% - meanForecastData : A double with size nobs x nvar with the mean 
%                      forecast. If empty it will be calculated.
%
% - forecastData     : A double with size nobs x nvar x nsim with the 
%                      density forecast.
%
% Output:
%
% - fcstEval : A Struct with the following properties:
% 
%               > (x)     : The evaluation score. As a nHor x nvar 
%                           double.
%
%               > density : A 1 x nVar cell. Each element consist of nHor  
%                           x nPoints. For each variable the values of   
%                           the density at the given points is stored.
%
%               > int     : A 1 x nVar cell. Each element consist of nHor 
%                           x nPoints. For each variable the points where 
%                           the density is evaluated is stored. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        meanForecastData = [];
    end
    
    if isempty(type)
        type = {};
    end
    
    if ischar(type)
        type = cellstr(type);
    end
    
    if isempty(meanForecastData)
        meanForecastData = mean(forecastData,3);
    end
    
    % Then evaluate the forecast
    for kk = 1:length(type)
        
        switch lower(type{kk})
            case 'se'
                score   = (data - meanForecastData).^2;
            case 'abs'
                score   = abs(data - meanForecastData);
            case 'diff'
                score   = data - meanForecastData;
            case 'logscore'

                    % Evaluate forecast using a normal density 
                    % approximation and then evaluate the log score at the
                    % point of the true data
                    meanF         = mean(forecastData,3);
                    stdF          = std(forecastData,1,3);   
                    densityNormal = @(x) normpdf(x, meanF, stdF);
                    score         = log(densityNormal(data));   
                    
            otherwise
                error([mfilename ':: Unsupported forecast evaluation ' type{kk} '.'])
        end
        fcstEval.(upper(type{kk})) = score;
        
    end
    
    fcstEval.int     = int;
    fcstEval.density = density;
    fcstEval.type    = '';

end

%==========================================================================
% [~,nVar,nPer] = size(density);
% nHor          = size(density{1},1);
%
% % Evaluate forecast using a kernel estimate of the density
% % and some grid points and then evaluate the log score at the
% % point of the true data
% score   = nan(nHor,nVar);
% for ii = 1:nVar
% 
%     domain  = int{ii};
%     nDom    = size(domain,2);
%     actual  = data(:,ii);
%     isNan   = isnan(actual);
%     domain  = domain(ones(1,nHor),:);
%     actual  = actual(:,ones(1,nDom));
%     diffAD  = (domain - actual).^2;
%     [~,ind] = min(diffAD,[],2);
%     ind     = ind(~isNan);
%     %binsL   = domain(1,2) - domain(1,1);
%     for jj = 1:size(ind,1)
%         score(jj,ii) = log(density{ii}(jj,ind(jj)));
%     end
% 
% end           
