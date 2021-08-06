function [index,calendar] = selectCalendar(obj,modelGroup,start,finish,doRecursive,fromResults)
% Syntax:
%
% [index,calendar] = selectCalendar(obj,modelGroup,start,finish,...
%   doRecursive,fromResults)
%
% Description:
%
% Select the forecasts that matches the supplied calendar for each
% model/model group.
% 
% Input:
% 
% - obj         : An object of a subclass of the nb_calendar class.
%
% - modelGroup  : A vector of objects of class nb_model_forecast_vintages.
% 
% - start       : Start date of calendar window, as a nb_day object.
%
% - finish      : End date of calendar window, as a nb_day object.
%
% - doRecursive : If the modelGroup input is a scalar 
%                 nb_model_group_vintages object you may want to get the
%                 calender of the children instead of the object itself.
%                 In this case this input must be set to true. Default
%                 is true.
%
% Output:
% 
% - index    : The index for each model that matches the provided calendar,
%              as a 1 x nModel cell array. Each element stores a numerical 
%              array with the indexes of the forecasts of the given 
%              calendar. 
%
% - calendar : The calendar used for the given model.
%
% See also:
% nb_model_group_vintages.constructWeights
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        fromResults = false;
        if nargin < 5
            doRecursive = true;
        end
    end

    calendar = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults);
    if isscalar(modelGroup) && isa(modelGroup,'nb_model_group_vintages') && doRecursive
        index = cell(1,length(modelGroup.models));
        for ii = 1:length(modelGroup.models)
            index{ii} = nb_calendar.doOneModel(modelGroup.models(ii),calendar);
        end
    elseif isa(modelGroup,'nb_model_forecast_vintages') || isa(modelGroup,'nb_calculate_vintages')
        index = cell(1,length(modelGroup));
        for ii = 1:length(modelGroup)
            index{ii} = nb_calendar.doOneModel(modelGroup(ii),calendar);
        end
    else
        error([mfilename ':: The modelGroup cannot be of class ' class(modelGroup) '.'])
    end
    
end
