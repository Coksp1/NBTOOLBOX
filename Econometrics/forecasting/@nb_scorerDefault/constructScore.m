function score = constructScore(forecastOutput,allVars,contexts,type,nSteps,rollingWindow,lambda)
% Syntax:
%
% score = nb_scorerDefault.constructScore(forecastOutput,allVars,...
%           contexts,type)
% score = nb_scorerDefault.constructScore(forecastOutput,allVars,...
%           contexts,type,nSteps,rollingWindow,lambda)
%
% Description:
%
% Construct forecast evaluation score given forecast output.
% 
% Input:
% 
% - forecastOutput : See the forecastOutput property of the 
%                    nb_model_forecast_vintages class.
%
% - allVars        : A cellstr with the variables to score. If a variable
%                    is not found to be forecasted by this model, a 0 
%                    score is given for that variable. If given as empty
%                    the score of all the variables forecasted by this 
%                    model is returned.
%
% - contexts       : A 1 x nContexts cellstr with the evaluation dates to
%                    calculate the score over. Each date must be on the
%                    format 'yyyymmdd'. Or a 1 x nContexts numerical array
%                    with the indexes of the forecast to evaluate. If empty
%                    a scalar 0 is returned.
%
% - type           : A string with one of the following:
%                    - 'RMSE'  : One over root mean squared error.
%                    - 'MSE'   : One over mean squared error.
%                    - 'SMSE'  : One over squared mean squared error.
%                    - 'RMAE'  : One over root mean absolute error.
%                    - 'MAE'   : One over mean absolute error.
%                    - 'SMAE'  : One over squared mean absolute error.
%                    - 'ME'    : Mean error.
%                    - 'STD'   : One over Standard error of the forecast 
%                                error.
%                    - 'ESLS'  : Exponential of the sum of the log scores.
%                    - 'EELS'  : Exponential of the mean of the log scores.
%                    - 'MLS'   : Mean log score.
% 
% - nSteps         : Select the number of forecasting steps. Can be
%                    empty.
%
% - rollingWindow  : Set it to a number if the combination weights are to 
%                    be calculated using a rolling window. Default is 
%                    empty, i.e. to calculate the weights recursively using 
%                    the the full history at each recursive step. 
%
% - lambda         : Give the value of the parameter of the exponential  
%                    decaying weights on past forecast errors when 
%                    constructing the score. If empty the weights on all 
%                    past forecast errors are equal.
%
% Output:
% 
% - score : As a nHor x nVar
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 7
        lambda = [];
        if nargin < 6
            rollingWindow = [];
            if nargin < 5
                nSteps = [];
            end
        end
    end
    
    if isempty(contexts)
        score = 0;
        return
    end
    
    if isempty(nSteps)
        nSteps = max([forecastOutput.forecast.nSteps]);
    end
    [evalType,type] = nb_scoreType2evalType(type);
    
    vars = {forecastOutput.forecast.variable};
    if isempty(allVars)
        allVars = {forecastOutput.forecast.variable};
    end
    nVars = length(allVars);
    if isnumeric(contexts)
        indC = contexts;
    else
        indC = nb_model_forecast_vintages.getContextIndex(forecastOutput.context,contexts); % Same context dates for all variables!
    end
    score     = zeros(nSteps,nVars);
    [ind,loc] = ismember(allVars,vars);
    for vv = 1:nVars
        if ind(vv)
            score(:,vv) = scoreOneVar(forecastOutput.forecast(loc(vv)),indC,type,nSteps,rollingWindow,lambda,evalType);
        end
    end
     
end

%==========================================================================
function score = scoreOneVar(forecast,indC,type,nSteps,rollingWindow,lambda,evalType)

    mSteps = nSteps;
    if nSteps > forecast.nSteps
        nSteps = forecast.nSteps;
    end

    nPer  = size(indC,2);
    tt    = getTT(rollingWindow,nPer);
    dates = forecast.start(indC);
    switch lower(type)
        
        case {'mse','rmse','smse'} % Mean squared error
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate MSE you need to have calculated squared errors with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
            
            % Then calculate the MSE
            score = meanScore(fcstEval,tt,lambda);
            if strcmpi(type,'rmse')
               score = sqrt(score); 
            elseif strcmpi(type,'smse')
               score = score.^2; 
            end
            score = 1./score;
            
        case {'mae','rmae','smae'} % Mean absolute error
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate MAE you need to have calculated absolute errors with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
            
            % Then calculate the MSE
            score = meanScore(fcstEval,tt,lambda);
            if strcmpi(type,'rmae')
               score = sqrt(score); 
            elseif strcmpi(type,'smae')
               score = score.^2; 
            end
            score = 1./score;
            
        case 'std' % Standard error of forecast
            
            if ~isempty(lambda)
                error([mfilename ':: The exponential decay option is not suported for score STD.'])
            end
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate STD you need to have calculated forecast errors (diff with actual) with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
            
            % Then calculate the STD
            fcstEvalT = fcstEval(:,tt:end);
            score     = nanstd(fcstEvalT,1,2); 
            score     = 1./score;
            
        case {'me','mean'}
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate MEAN you need to have calculated forecast errors (diff with actual) with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
            
            % Then calculate the score
            score = meanScore(fcstEval,tt,lambda);
            
        case {'esls','sls'}
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate ESLS you need to have calculated log scores with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
            
            % Then calculate the ESLS
            score = sumScore(fcstEval,tt,lambda);
            if strcmpi(type,'esls')
                score = exp(score);
            end 
            
        case {'eels','mls'}
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = forecast.evaluation.(evalType);
            catch %#ok<CTCH>
                error([mfilename ':: To calculate ' upper(type) ' you need to have calculated log scores with the '...
                                'evaluateForecast method. See the fcstEval input of that method.'])
            end
            fcstEval = fcstEval(1:nSteps,indC);
            fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates);
                       
            % Then calculate the EELS
            score = meanScore(fcstEval,tt,lambda);
            if strcmpi(type,'eels')
                score = exp(score);
            end 
            
        otherwise 
            error([mfilename ':: Unsupported forecast evaluation type ' type])
    
    end
    
    if mSteps > nSteps
        score = [score; nan(mSteps - nSteps,size(score,2),size(score,3))];
    end
    
end

%==========================================================================
function tt = getTT(rollingWindow,nPer)

    if rollingWindow
        tt = max(nPer - rollingWindow + 1,1);
    else
        tt = 1;
    end

end

%==========================================================================
function score = meanScore(fcstEval,tt,lambda)

    fcstEvalT = fcstEval(:,tt:end);
    if ~isempty(lambda)
        score = nb_exponentialDecayingMean(fcstEvalT,lambda,2);
    else
        score = nanmean(fcstEvalT,2);
    end
    ind        = all(isnan(fcstEvalT),2);
    score(ind) = nan;

end

%==========================================================================
function score = sumScore(fcstEval,tt,lambda)

    fcstEvalT = fcstEval(:,tt:end);
    if ~isempty(lambda)
        score = nb_exponentialDecayingSum(fcstEvalT,lambda,2);
    else
        score = nansum(fcstEvalT,2);
    end 
    ind        = all(isnan(fcstEvalT),2);
    score(ind) = nan;


end

%==========================================================================
function fcstEval = stripInfoNotAvailableAtTheTime(fcstEval,dates)

    nHor            = size(fcstEval,1);
    fcstEval(:,end) = nan;
    current         = dates(end);
    start           = 1;
    for ii = size(dates,2)-1:-1:1
        if ~strcmpi(current,dates{ii})
            start   = start + 1; 
            current = dates{ii};
        end
        if start > nHor
            break
        end
        fcstEval(start:end,ii) = nan;     
    end

end
