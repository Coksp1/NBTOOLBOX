function [evaluation,errorDates] = evalFcstAtDates(obj, dates, type, density, quart)
% Syntax:
%
% [evaluation,errorDates] = evalFcstAtDates(obj, dates, type, density,...
%                           quart)
%
% Description:
%
% Evaluates a models forecasting capabilities compared to actual data. If   
% a date is given before day number 15 it uses data from up until two
% months before. If a date is given on day number 15 or later, it uses data
% from up until one month before the date. For quarterly data it uses
% the same, but restricted to also beeing in the first month in the 
% quarter, i.e. if it is the second or third month it will always use
% data up until one quarter before the released.
% 
% Input:
% 
% - obj     : A nb_model_generic or nb_model_group object containing 
%             forecasts.
%
% - dates   : A cellstring containing the dates that the forecast should 
%             be evaluated at. Can also be a nb_date object.
%
% - type    : The evaluation criteria. A cellstr with one or more of the 
%             following:
%              - 'RMSE'  : Root mean squared error
%              - 'MSE'   : Mean squared error
%              - 'MAE'   : Mean absolute error
%              - 'MEAN'  : Mean error
%              - 'STD'   : Standard error of the forecast error
%              - 'ESLS'  : Exponential of the sum of the log scores
%              - 'EELS'  : Exponential of the mean of the log scores
%              - 'MLS'   : Mean log score
%
% - density : Set true if you have a density forecast.
%
% - quart   : Set true if you want to compare the quarterly forecasts. This
%             option automatically detects and uses the quarterly estimates
%             when evaluating. 
% 
% Output:
% 
% - evaluation : A nb_data object with the evaluation scores for each 
%                observation and variable.
%
% - errorDates : Since it is not always the case that all of the dates are
%                being used, errorDates returns those dates as a
%                cellstr.
%
% Examples:
%
% m = evalFcstAtDates(b,d,{'MSE'},0,1)
% m = evalFcstAtDates(b,d,{'MSE','RMSE'},0,1)
%
% See also:
% nb_evalForecastfromFame
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: This function takes only one nb_model_generic object as input. Not a vector!'])
    end
    
    typet = cell(1,length(type));
    type  = upper(type);
    for ii = 1:length(type)
        switch type{ii}
            case {'RMSE','MSE'}
                typet{ii} = 'se';
            case 'MAE'
                typet{ii} = 'abs';
            case {'ME','STD'}
                typet{ii} = 'diff';
            case {'EELS','ESLS'}
                if density
                    typet{ii} = 'logScore';
                else
                    error([mfilename '::' type{ii} 'only works for density forecast evaluation. '])
                end
            otherwise
                error([mfilename ':: Unsupported forecast evaluation type ' type{ii}])
        end
    end
    convert = false;
    if ~isa(dates,'nb_day')
        dates   = nb_date.vintage2Date(dates,365);
        convert = true; 
    end
    data      = obj.forecastOutput.data;
    startFcst = obj.forecastOutput.start;
    [~,freq]  = nb_date.date2freq(startFcst);
    if ~any(freq == [4,12])
        error('This method only allow quarterly or monthly data. ')
    end

    % Determine wether MPR is before or after the 15. of each month.
    vector = false(length(dates),1);
    if freq == 12
        for ii = 1:length(dates)
            vector(ii) = dates(ii) > dates(ii).getMonth.getDay + 13;
        end
    else
        for ii = 1:length(dates)
            vector(ii) = dates(ii) > dates(ii).getQuarter.getMonth.getDay + 13;
        end
    end

    switch density
        case 0
            func = @nb_evaluateForecast;
        case 1
            func = @nb_evaluateDensityForecastOnlyScore;
        otherwise
            error('Unsupported input given to density. Please choose either 0 or 1')
    end

    % Extract the actual observations
    histData = getHistory(obj,obj.forecastOutput.variables);
    try
        histData = reorder(histData,obj.forecastOutput.variables);
    catch %#ok<CTCH>
        error([mfilename ':: Could not get the historical data on all the variables of the model.'])
    end
    actual = window(histData,startFcst{1},startFcst{end-1});
    actual = [actual.data;nan(1,size(actual.data,2))];
    actual = nb_splitSample(actual,obj.forecastOutput.nSteps);

    % If quarterly is set to true, find the correct quarterly forecasts 
    % and actual observations.
    if quart
        r        = obj.forecastOutput.start(:);
        rt       = cellfun(@(v) v(6:end), r,  'UniformOutput',false);
        rtt      = ceil(str2double(rt(:))/3);
        t        = 1 + rtt*3;
        s        = t - str2double(rt(:));
        fcstData = nan(length(1:3:obj.forecastOutput.nSteps),...
                       length(obj.forecastOutput.variables),1,...
                       length(obj.forecastOutput.start));
        actData  = fcstData;
        for ii = 1:length(startFcst)
            % Forecast
            temp = data(s(ii):3:obj.forecastOutput.nSteps,:,1,ii);
            fcstData(1:size(temp,1),:,1,ii) = temp;

            % Actual
            temptemp = actual(s(ii):3:obj.forecastOutput.nSteps,:,ii);
            actData(1:size(temptemp,1),:,ii) = temptemp;
        end
        data   = fcstData;
        actual = actData;
    end
    evaluation = zeros(size(data,1)-1,size(data,2),length(dates),length(typet));
    actual     = actual(1:end-1,:,:);

    % Evaluate the forecasts against actual observations.
    keep = true(1,length(dates));
    for ii = 1:length(dates)

        if freq == 12
            date = getMonth(dates(ii));
            date = toString(date);
        else
            date = getQuarter(dates(ii));
            date = toString(date);
        end
        ind = find(strcmpi(date,startFcst));
        if isempty(ind)
            keep(ii) = false;
            continue
        end
        if vector(ii)
            datat = data(1:end-1,:,:,ind);
        else
            datat = data(2:end,:,:,ind-1);
        end

        for jj = 1:length(typet)
            evaluation(:,:,ii,jj) = func(typet{jj},actual(:,:,ind),datat);
        end

    end

    evaluation = evaluation(:,:,keep,:);
    errorDates = dates(~keep);
    if convert
        errorDates = toString(errorDates);
        if isempty(errorDates)
            errorDates = {};
        end
    end
    
    % Construct the scores according to the chosen evaluation criterias.
    for ii = 1:length(type)
        switch type{ii}
            case 'RMSE'
                evaluation = nanmean(evaluation,3);
                evaluation = evaluation.^0.5;
            case {'MSE','MAE'}
                evaluation = nanmean(evaluation,3);
            case 'ME'
                evaluation = nanmean(evaluation,3);
            case 'STD'
                evaluation = nanstd(evaluation,3);
            case 'EELS'
                evaluation = exp(nanmean(evaluation));
            case 'ESLS'
                evaluation = exp(nansum(evaluation,3));
            case 'MLS'
                evaluation = nanmean(evaluation,3);
            otherwise
                error([mfilename ':: Unsupported forecast evaluation type ' type{ii}])
        end
    end
    evaluation = permute(evaluation,[1,2,4,3]);
    evaluation = nb_data(evaluation,'',1,obj.forecastOutput.variables);
    
end
