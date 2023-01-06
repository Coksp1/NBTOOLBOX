function [score,start] = constructScoreLowFreq(forecastOutput,type,freq,highPeriod,allPeriods,startDate,endDate,rollingWindow,lambda)
% Syntax:
%
% score = nb_mfvar.constructScoreLowFreq(forecastOutput,type,freq)
% [score,start] = nb_mfvar.constructScoreLowFreq(forecastOutput,type,...
%                   freq,highPeriod,allPeriods,startDate,endDate,...
%                   rollingWindow,lambda)
%
% Description:
%
% Construct forecast evaluation score given forecast output.
% 
% Input:
% 
% - forecastOutput : See the forecastOutput property of the 
%                    nb_model_generic class
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
% - freq           : The frequency of the evaluated forecast. Only the
%                    variables observed at this frequency are evaluated.
%
% - highPeriod     : Give 0 to get the forecast when the data of low and  
%                    high frequency is balanced, 1 if the high frequency  
%                    data has one more observation, and so on. Default is 
%                    0.   
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
% nb_mfvar.getScoreLowFreq
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 9
        lambda = [];
        if nargin < 8
            rollingWindow = [];
            if nargin < 7
                endDate = '';
                if nargin < 6
                    startDate = '';
                    if nargin < 5
                        allPeriods = false;
                        if nargin < 4
                            highPeriod = 0;
                        end
                    end
                end
            end
        end
    end
    
    % Get the evaluated recursive periods
    start  = forecastOutput.start;
    vars   = forecastOutput.dependent;
    nVars  = length(vars);
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
    startObj = nb_date.date2freq(start{indS});
    endObj   = nb_date.date2freq(start{indE});
    nPer     = (endObj - startObj) + 1;
    [~,ind]  = toDates(startObj,0:nPer - 1,'default',freq);
    ind      = ind + highPeriod - 1;
    ind      = ind(ind > 0 & ind <= nPer);

    % Get the evaluation results
    switch lower(type)
        case {'mse','rmse'}
            evalType = 'SE';
        case 'mae'
            evalType = 'ABS';
        case {'me','mean','std'}
            evalType = 'DIFF';
        case {'esls','eels','mls'}
            evalType = 'LOGSCORE';
        otherwise 
            error([mfilename ':: Unsupported forecast evaluation type ' type]) 
    end   
    evalType = [evalType,'_',int2str(freq)];
    evalC    = {forecastOutput.evaluation(ind).(evalType)};
    nHor     = cellfun(@(x)size(x,1),evalC);
    maxHor   = max(nHor);
    for ii = find(nHor ~= maxHor)
        evalC{ii} = [evalC{ii};nan(maxHor - nHor(ii),size(evalC{ii},2))];
    end
    fcstEval = [evalC{:}];
    periods  = size(ind,1);
    fcstEval = reshape(fcstEval,[maxHor,nVars,periods]);
    tt       = getTT(allPeriods,rollingWindow,periods);
    
    % Then calculate the score
    switch lower(type)
        
        case {'mse','rmse'} % (Root) Mean squared error
            
            score = meanScore(fcstEval,allPeriods,tt,lambda,periods);
            if strcmpi(type,'rmse')
               score = sqrt(score); 
            end
            score = 1./score;
            
        case 'mae' % Mean absolute error
           
            % Then calculate the MSE
            score = meanScore(fcstEval,allPeriods,tt,lambda,periods);
            score = 1./score;
            
        case 'std' % Standard error of forecast
            
            if ~isempty(lambda)
                error([mfilename ':: The exponential decay option is not suported for score STD.'])
            end
            
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
            
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            
        case 'esls'
            
            score = sumScore(fcstEval,allPeriods,tt,lambda,nPer);
            score = exp(score);
            
        case {'eels','mls'}
            
            score = meanScore(fcstEval,allPeriods,tt,lambda,nPer);
            if strcmpi(type,'eels')
                score = exp(score);
            end 
            
        otherwise 
            error([mfilename ':: Unsupported forecast evaluation type ' type])
    
    end
    
    if nargout > 1
        start = start(indS:indE);
        if allPeriods
            start = start(ind);
        else
            start = start(end); 
        end
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
