function [index,calendar] = selectRecursiveCalendar(obj,modelGroup,start,finish,doRecursive)
% Syntax:
%
% [index,calendar] = selectRecursiveCalendar(obj,modelGroup,start,finish,doRecursive)
%
% Description:
%
% Select the forecast that matches the supplied calendar for each
% model/model group recursivly.
% 
% Input:
% 
% - obj         : An object of a subclass of the nb_calendar class.
%
% - modelGroup  : A vector of objects of class nb_model_forecast_vintages.
% 
% - start       : Start date of calendar window, as a nb_day object.
%
% - finish      : A 1 x nContext array of nb_day objects. Each element is
%                 the end date of each recursive window.
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
%              as a 1 x nModel cell array, each element consisting of  
%              1 x nRec cell array, where nRec is the number of recursive 
%              periods. Each element of these again stores a numerical 
%              array with the indexes of the forecasts of the given 
%              calendar of a given recursive evaluation period. 
%
% - calendar : A 1 x nRec cell array, where nRec is the number of recursive 
%              periods. Each element of these again stores a the calendar
%              of each recursive period.
%
% See also:
% nb_model_group_vintages.constructWeights
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        doRecursive = true;
    end

    % Get the calendar for each recursive sample window.
    nRec     = length(finish);
    calendar = cell(1,nRec);
    for ff = 1:nRec
        calendar{ff} = getCalendar(obj,start,finish(ff),modelGroup,doRecursive);
    end
    
    % Get the forecasts of each calendar for each model 
    if isscalar(modelGroup) && isa(modelGroup,'nb_model_group_vintages') && doRecursive
        index = cell(1,length(modelGroup.models));
        for ii = 1:length(modelGroup.models)
            if modelGroup.models(ii).valid
                indexRec = cell(1,nRec);
                for ff = 1:nRec
                    indexRec{ff} = nb_calendar.doOneModel(modelGroup.models(ii),calendar{ff});
                end
                index{ii} = indexRec; 
            end
        end
    elseif isa(modelGroup,'nb_model_forecast_vintages')
        index = cell(1,length(modelGroup));
        for ii = 1:length(modelGroup)
            if modelGroup(ii).valid
                indexRec = cell(1,nRec);
                for ff = 1:nRec
                    indexRec{ff} = nb_calendar.doOneModel(modelGroup(ii),calendar{ff});
                end
                index{ii} = indexRec;
            end
        end
    else
        error([mfilename ':: The modelGroup cannot be of class ' class(modelGroup) '.'])
    end
    
end
