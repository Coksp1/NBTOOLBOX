function start = getDefaultStart(modelGroup,doRecursive,fromResults)
% Syntax:
%
% start = nb_calendar.getDefaultStart(modelGroup,doRecursive,fromResults)
%
% Description:
%
% Get default start of calendar if the modelGroup is provide.
% 
% Input:
% 
% - modelGroup  : A vector of objects of class nb_model_forecast_vintages.
% 
% - doRecursive : If the modelGroup input is a scalar 
%                 nb_model_group_vintages object you may want to get the
%                 calender of the children instead of the object itself.
%                 In this case this input must be set to true. Default
%                 is true.
%
% - fromResults : Give true to take the contexts from results
%                 property instead of the forecastOutput property.
%
%                 This is only supported when modelGroup is an
%                 array of nb_model_vintages objects.
% 
% Output:
% 
% - start      : The default start date of the calendar. As a nb_day 
%                object. Is empty ('') if modelGroup is empty.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if length(modelGroup) == 0 %#ok<ISMT>
        start = '';
    else
        contextsStart = nb_calendar.getStartOfCalendar(modelGroup,doRecursive,fromResults);
        ind           = cellfun(@isempty,contextsStart);
        contextsStart = contextsStart(~ind);
        contextsStart = nb_convertContexts(contextsStart);
        contextsStart = min(contextsStart); % min is needed in constructing scores and weights. Why did we have max here??
        start         = nb_day(num2str(contextsStart));
    end
    
end
