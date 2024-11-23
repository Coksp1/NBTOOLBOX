function fcstEval = nb_evaluateDensity(type,data,density,int,meanForecastData,forecastData,dist)
% Syntax:
%
% fcstEval = nb_evaluateDensityForecast(type,data,density,domain,...
%                           meanForecastData,forecastData,dist)
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
% - dist             : A nHor x nVars x nPeriods nb_distribution object.
%                      If this input is provided, these distributions will
%                      be the basis for the calculated log scores.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 7
        dist = [];
        if nargin < 5
            meanForecastData = [];
        end
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

                if ~isempty(dist)
                    if strcmpi(dist(1,1).type,'normal')
                        dist = []; % Use faster code instead in this case!
                    end
                end
                if ~isempty(dist)
                    nHor  = size(dist,1);
                    nVars = size(dist,2);
                    score = nan(nHor,nVars);
                    for hh = 1:nHor
                        for vv = 1:nVars
                            score(hh,vv) = log(pdf(dist(hh,vv),data(hh,vv)));
                        end
                    end
                else
                    % Evaluate forecast using a normal density 
                    % approximation and then evaluate the log score at the
                    % point of the true data
                    stdF          = std(forecastData,1,3);   
                    densityNormal = @(x) normpdf(x, meanForecastData, stdF);
                    score         = log(densityNormal(data));  
                end
                    
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
