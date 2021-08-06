function [score,plotter] = getRecursiveScore(obj,type,dim,startDate,endDate,invert)
% Syntax:
%
% score           = getRecursiveScore(obj,type)
% [score,plotter] = getRecursiveScore(obj,type,startDate,endDate,invert)
%
% Description:
%
% Get forecasting scores using recursive evaluation.
% 
% Input:
%
% - obj            : A vector of nb_model_forecast objects. 
% 
% - type           : A string with on of the following:
%                    - 'RMSE'  : Root mean squared error
%                    - 'MSE'   : Mean squared error
%                    - 'MAE'   : Mean absolute error
%                    - 'MEAN'  : Mean error
%                    - 'STD'   : Standard error of the forecast error
%                    - 'ESLS'  : Exponential of the sum of the log scores
%                    - 'EELS'  : Exponential of the mean of the log scores
%                    - 'MLS'   : Mean log score
% 
% - dim            : Either 'variables' to get the recursive scores of all
%                    the variables forecast by a model (the obj input must 
%                    be a scalar object), or else the name of the variable
%                    to get the score of (must be part of all models!).
%
% - startDate      : The date to begin constructing the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date.
%
% - endDate        : The date to end constructiong the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date.
%
% - invert         : true | false. Default true. If true it will invert the
%                    score for 'RMSE','MSE', 'MAE' and 'STD'.
%
% Output:
%
% - score   : A nb_ts object with size nPeriods x nVars x nHorizon if dim
%             equal 'variables', else a nb_ts object with size nPeriods x
%             nObj x nHorizon.
%
% - plotter : A nb_graph_ts object to plot the recursive scores. Use the
%             graph method. One figure per horizon!
%
% See also:
% nb_model_generic.forecast, nb_model_generic.constructScore
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        invert = true;
        if nargin < 5
            endDate = '';
            if nargin < 4
                startDate = '';
            end
        end
    end
    
    if ~isempty(startDate)
        if ~isa(startDate,'nb_date')
            startDate = nb_date.date2freq(startDate);
        end
    end
    
    if ~isempty(endDate)
        if ~isa(endDate,'nb_date')
            endDate = nb_date.date2freq(endDate);
        end
    end
    
    obj            = obj(:);
    nobj           = numel(obj);
    forecastOutput = {obj.forecastOutput};
    names          = getModelNames(obj);
    
    if strcmpi(dim,'variables')
        
        if numel(obj)>1
            error([mfilename ':: This function only handle a scalar nb_model_generic object.'])
        end 
        if isempty(startDate)
            startDate = nb_date.date2freq(forecastOutput{1}.start{1});
        end
        if isempty(endDate)
            endDate = nb_date.date2freq(forecastOutput{1}.start{end});
        end
        horNames = nb_appendIndexes('horizon',1-forecastOutput{1}.nowcast:forecastOutput{1}.nSteps)';
        if forecastOutput{1}.nowcast
            nowcast = max(sum(forecastOutput{1}.missing,1));
        else
            nowcast = 0;
        end
        minNow = nowcast;
        
    else
        
        % Get the final output size
        nHor      = nan(1,nobj);
        nowcast   = zeros(1,nobj);
        startFcst = cell(1,nobj);
        for ii = 1:nobj
            if forecastOutput{ii}.nowcast
                indV = find(strcmp(dim,forecastOutput{ii}.dependent),1);
                if isempty(indV)
                    error([mfilename ':: The selected variable must be part of ' names{ii} '.'])
                end
                nowcast(ii) = sum(forecastOutput{ii}.missing(:,indV));
            end
            nHor(ii)      = forecastOutput{ii}.nSteps;
            startFcst{ii} = forecastOutput{ii}.start;
        end
        maxNow = max(nowcast);
        minNow = min(nowcast);
        maxHor = max(nHor);
        mHor   = maxHor + maxNow;
        
        startFcst    = nb_date.intersect(startFcst{:});
        nDates       = length(startFcst);
        startFcst1   = nb_date.date2freq(startFcst{1});
        startFcstEnd = nb_date.date2freq(startFcst{end});
        if ~isempty(startDate)
            indS  = startDate - startFcst1 + 1;
            if indS < 1
                error([mfilename ':: The startDate input is before the intersection of start dates of the forecast from the models.'])
            elseif indS > nDates
                error([mfilename ':: The startDate input is after the intersection of end dates of the forecast from the models.'])
            end
            startFcst = startFcst(1,indS:end);
        else
            startDate = startFcst1;
        end

        if ~isempty(endDate)
            indE  = startFcstEnd - endDate;
            if indE < 0
                error([mfilename ':: The endDate input is after the intersection of end dates of the forecast from the models.'])
            elseif indE > nDates
                error([mfilename ':: The endDate input is before the intersection of start dates of the forecast from the models.'])
            end
            startFcst = startFcst(1,1:end-indE);
        else
            endDate = startFcstEnd;
        end
        nDates = length(startFcst);
        
        % Preallocation
        score    = nan(nDates,nobj,mHor);
        horNames = nb_appendIndexes('horizon',1-maxNow:maxHor)';
        
    end
        
    for ii = 1:nobj
        
        if nb_isempty(forecastOutput{ii})
            error([mfilename ':: You need to produce forecast using forecast for the model with name ' names{ii}])
        end
        
        try
            scoreV = nb_model_generic.constructScore(forecastOutput{ii},type,1,startDate + (nowcast(ii) - minNow),endDate + (nowcast(ii) - minNow) );
        catch Err
            error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model '...
                             'with name ' names{ii} '. Error:: ' Err.message])
        end
        
        if invert
            switch lower(type)
                case {'mse','rmse','mae','std'} 
                    scoreV = 1./scoreV;
            end
        end
        
        if strcmp(dim,'variables')
            score = permute(scoreV,[3,2,1]);
        else
            indV = find(strcmp(dim,forecastOutput{ii}.dependent),1);
            if isempty(indV)
                error([mfilename ':: The selected variable must be part of model ' names{ii} '.'])
            end
            if nowcast(ii) > 0
                sInd = size(forecastOutput{ii}.missing,1) - nowcast(ii) + 1;
                score(:,ii,1:nHor(ii)+nowcast(ii)) = permute(scoreV(sInd:end,indV,:),[3,2,1]);
            else
                score(:,ii,1:nHor(ii)) = permute(scoreV(:,indV,:),[3,2,1]);
            end
            
        end
        
    end
   
    if strcmp(dim,'variables')
        vars  = forecastOutput{ii}.dependent;
    else
        vars = names;
    end
    
    score = nb_ts(score,horNames,startDate,vars);
    
    if nargout > 1
        plotter = nb_graph_ts(score);
    end

end
