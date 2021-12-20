function actual = getActual(models,vars,startFcst,nSteps,inputs)
% Syntax:
%
% actual = nb_model_group.getActual(models,vars,startFcst,nSteps,inputs)
%
% Description:
%
% Get actual data to compare against the forecast. 
% 
% Input:
% 
% - models    : See the property models of the nb_model_group class.
%
% - vars      : A cellstr with the names of the variables to get the actual 
%               data of.
%
% - startFcst : The recursive forecasting periods. Either as a double
%               with the indecies or a cellstr with the dates.
%
% - nSteps    : Number of forecasting steps. If empty the sample will not
%               be split.
%
% - inputs    : A struct with some options passed to the 
%               nb_forecast.getActual function. Optional.
% 
% Output:
% 
% - actual : A nSteps x nVars x nPeriods double with the actual data for
%            each recursive forecast if nSteps is given, otherwise a nobs
%            x nVars double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        inputs = struct('compareTo','','compareToRev','');
    end

    startF   = nb_date.date2freq(startFcst{1});
    nPeriods = length(startFcst);
    test     = false(1,length(vars));
    if isempty(nSteps)
        actual = nan(nPeriods,length(vars));
    else
        actual = nan(nSteps,length(vars),nPeriods);
    end
    for ii = 1:length(models)
        depM       = models{ii}.forecastOutput.dependent;
        indM       = ismember(depM,vars);
        startD     = models{ii}.options.data.startDate;
        startFcstM = (startF - startD) + 1;
        if startFcstM > 0
            startFcstM = startFcstM:startFcstM + nPeriods - 1;
            if isa(models{ii},'nb_model_generic')
                actualM = nb_forecast.getActual(models{ii}.estOptions,inputs,models{ii}.solution,models{ii}.forecastOutput.nSteps,...
                                        models{ii}.forecastOutput.dependent,startFcstM,~isempty(nSteps));
            else
                actualM = nb_model_group.getActual(models{ii}.models,depM,startFcst,nSteps,inputs);
            end
            actual(:,indM,:) = actualM;
            test(indM)       = true;
        end
        if all(test)
            break;
        end
    end
    
end
