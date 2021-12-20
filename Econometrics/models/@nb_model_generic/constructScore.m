function score = constructScore(forecastOutput,type,allPeriods,startDate,endDate,nSteps,rollingWindow,lambda)
% Syntax:
%
% score = nb_model_generic.constructScore(forecastOutput,type)
% score = nb_model_generic.constructScore(forecastOutput,type,...
%                allPeriods,startDate,endDate,nSteps,rollingWindow,lambda)
%
% Description:
%
% Construct forecast evaluation score given forecast output.
% 
% Input:
% 
% - forecastOutput : See the forecastOutput property of the 
%                    nb_model_forecast class
%
% - type           : A string with one of the following:
%                    - 'RMSE'  : One over root mean squared error.
%                    - 'MSE'   : One over mean squared error.
%                    - 'MAE'   : One over mean absolute error.
%                    - 'ME'    : Mean error.
%                    - 'STD'   : One over Standard error of the forecast 
%                                error.
%                    - 'ESLS'  : Exponential of the sum of the log scores.
%                    - 'EELS'  : Exponential of the mean of the log scores.
%                    - 'MLS'   : Mean log score.
% 
% - allPeriods     : true if you want the scores to be calculated for all 
%                    periods recursively, or else give false, i.e. only 
%                    calculate the score for the last period. False is
%                    default.
%
% - startDate      : The date to begin constructing the score. Can be
%                    empty.
%
% - endDate        : The date to end constructing the score. Can be
%                    empty.
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
% - score : As a nHor x nVar x nPeriods
%
% See also:
% nb_model_forecast.getScore
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        lambda = [];
        if nargin < 7
            rollingWindow = [];
            if nargin < 6
                nSteps = [];
                if nargin < 5
                    endDate = '';
                    if nargin < 4
                        startDate = '';
                        if nargin < 3
                            allPeriods = false;
                        end
                    end
                end
            end
        end
    end
    
    if isempty(nSteps)
        nSteps = forecastOutput.nSteps;
    else
        if nSteps > forecastOutput.nSteps
            error([mfilename ':: The nSteps input is outside bounds'])
        end
    end
    if isfield(forecastOutput,'missing')
        if ~isempty(forecastOutput.missing)
            nSteps = nSteps + forecastOutput.nowcast;
        end
    end
    
    start  = forecastOutput.start;
    vars   = forecastOutput.dependent;
    nVars  = length(vars);
    nPer   = size(forecastOutput.start,2);
    indS   = 1;
    indE   = length(start);
    if ~isempty(startDate)
       
        if isa(startDate,'nb_date')
            startDate = toString(startDate);
        end
        indS = find(strcmpi(startDate,start),1);
        if isempty(indS)
            error([mfilename ':: The provided start date is outside bounds'])
        end
        
    end
    
    if ~isempty(endDate)
       
        if isa(endDate,'nb_date')
            endDate = toString(endDate);
        end
        indE = find(strcmpi(endDate,start),1);
        if isempty(indE)
            error([mfilename ':: The provided end date is outside bounds'])
        end
        
    end
    
    switch lower(type)
        
        case {'mse','rmse'} % Mean squared error
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.SE];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate ' upper(type) ' you need to have calculated squared errors while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end
           
            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);

            % Then calculate the MSE
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            if strcmpi(type,'rmse')
               score = sqrt(score); 
            end
            score = 1./score;
            
        case 'mae' % Mean absolute error
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.ABS];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate MAE you need to have calculated absolute errors while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end
           
            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);
            
            % Then calculate the MSE
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            score = 1./score;
            
        case 'std' % Standard error of forecast
            
            if ~isempty(lambda)
                error([mfilename ':: The exponential decay option is not suported for score STD.'])
            end
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.DIFF];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate STD you need to have calculated forecast errors (diff with actual) while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end
           
            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);
            
            % Then calculate the STD
            if allPeriods
                
                score = fcstEval;
                for ii = 1:nPer
                    fcstEvalT     = fcstEval(:,:,tt(ii):ii);
                    score(:,:,ii) = nanstd(fcstEvalT,1,3);
                end
                
            else
                fcstEvalT = fcstEval(:,:,tt:end);
                score     = nanstd(fcstEvalT,1,3); 
            end
            score = 1./score;
            
        case {'me','mean'}
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.DIFF];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate MEAN you need to have calculated forecast errors (diff with actual) while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end
           
            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);
            
            % Then calculate the score
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            
        case 'esls'
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.LOGSCORE];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate ESLS you need to have calculated log scores while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end

            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);
            
            % Then calculate the ESLS
            score = sumScore(fcstEval,allPeriods,tt,lambda,nPer);
            score = exp(score);
            
        case {'eels','mls'}
            
            % Get the score by period stacked in the third dim
            try
                fcstEval = [forecastOutput.evaluation.LOGSCORE];
            catch %#ok<CTCH>
                error([mfilename ':: To calculate ESLS you need to have calculated log scores while forecasting. '...
                                'See the fcstEval input of the nb_model_generic.uncondForecast method'])
            end

            if isstruct(fcstEval) % Old version
                fcstEval = [fcstEval.score]; % I.e. density eval
            end
            nHor     = size(fcstEval,1);
            fcstEval = reshape(fcstEval,[nHor,nVars,nPer]);
            fcstEval = fcstEval(1:nSteps,:,indS:indE);
            nPer     = indE - indS + 1;
            tt       = getTT(allPeriods,rollingWindow,nPer);
            
            % Then calculate the EELS
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            if strcmpi(type,'eels')
                score = exp(score);
            end 
            
        otherwise 
            error([mfilename ':: Unsupported forecast evaluation type ' type])
    
    end
      
end

%==========================================================================
function tt = getTT(allPeriods,rollingWindow,nPer)

    if allPeriods
        if rollingWindow
            tt       = 1:nPer;
            tt       = tt - (rollingWindow - 1);
            tt(tt<1) = 1;
        else
            tt = ones(1,nPer);
        end
    else
        if rollingWindow
            tt = max(nPer - rollingWindow + 1,1);
        else
            tt = 1;
        end
    end

end

%==========================================================================
function score = meanScore(fcstEval,allPeriods,tt,lambda,nPer)

    if allPeriods
                
        score = fcstEval;
        for ii = 1:nPer
            fcstEvalT = fcstEval(:,:,tt(ii):ii);
            if ~isempty(lambda)
                score(:,:,ii) = nb_exponentialDecayingMean(fcstEvalT,lambda,3);
            else
                score(:,:,ii) = nanmean(fcstEvalT,3);
            end
        end

    else
        fcstEvalT = fcstEval(:,:,tt:end);
        if ~isempty(lambda)
            score = nb_exponentialDecayingMean(fcstEvalT,lambda,3);
        else
            score = nanmean(fcstEvalT,3);
        end 
    end

end

%==========================================================================
function score = sumScore(fcstEval,allPeriods,tt,lambda,nPer)

    if allPeriods
                
        score = fcstEval;
        for ii = 1:nPer
            fcstEvalT = fcstEval(:,:,tt(ii):ii);
            if ~isempty(lambda)
                score(:,:,ii) = nb_exponentialDecayingSum(fcstEvalT,lambda,3);
            else
                score(:,:,ii) = nansum(fcstEvalT,3);
            end
        end

    else
        fcstEvalT = fcstEval(:,:,tt:end);
        if ~isempty(lambda)
            score = nb_exponentialDecayingSum(fcstEvalT,lambda,3);
        else
            score = nansum(fcstEvalT,3);
        end 
    end

end
