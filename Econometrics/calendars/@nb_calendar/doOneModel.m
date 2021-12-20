function [index,isMatch] = doOneModel(model,calendar)
% Syntax:
%
% [index,isMatch] = nb_calendar.doOneModel(model,calendar)
%
% Description:
%
% Shrink calendar to a provided window.
% 
% Input:
% 
% - model    : The model of interest. As a nb_model_vintages object.
%
%              or
%
%              A cellstr with the contexts of a model. Each element on the
%              format 'yyyymmdd'.
%
% - calendar : Full calendar as a N x 1 double.
%
% Output:
% 
% - index    : The index for the model that matches the provided calendar,
%              as a 1 x N numerical array, where N is the length of the 
%              calendar. 
%
% - isMatch  : A 1 x N logical array, if false it means that the model 
%              doesn't provide a forecast at the given date, where N is  
%              the length of the calendar. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the contexts of this model as double
    if isa(model,'nb_model_forecast_vintages')
        contexts = nb_convertContexts(model.forecastOutput.context);
    elseif isa(model,'nb_calculate_vintages')
        contexts = nb_convertContexts(model.results.data.dataNames);    
    elseif iscellstr(model)
        contexts = nb_convertContexts(model);
    else
        error([mfilename ':: The model input must be a nb_model_forecast_vintages object or a cellstr.'])
    end
    
    % Get the index of the forecast that match the calendar
    [index,isMatch] = nb_calendar.getContextIndex(contexts,calendar);
    
end
