function contextsStart = getStartOfCalendar(modelGroup,doRecursive,fromResults) 
% Syntax:
%
% contextsStart = nb_calendar.getStartOfCalendar(modelGroup,doRecursive,...
%                   fromResults) 
%
% Description:
%
% Get first context of a set of nb_model_forecast_vintages, or the children
% of a scalar nb_model_group_vintages object.
% 
% Input:
% 
% - modelGroup  : A vector of objects of class nb_model_forecast_vintages.
%
% - doRecursive : If the modelGroup input is a scalar 
%                 nb_model_group_vintages object you may want to 
%                 get the calender of the children instead of the 
%                 object itself. In this case this input must be 
%                 set to true. Default is true.
%
% - fromResults : Give true to take the contexts from results
%                 property instead of the forecastOutput property.
%
%                 This is only supported when modelGroup is an
%                 array of nb_model_vintages objects.
% 
% Output:
% 
% - contextsStart : A cellstr array with same length as the modelGroup
%                   input, each element stores the first context of the
%                   that particular model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isscalar(modelGroup) && isa(modelGroup,'nb_model_group_vintages') && doRecursive
        if fromResults
            error([mfilename ':: Cannot fetch contexts from objects of class nb_model_group_vintages.'])
        end
        contextsStart = cell(1,length(modelGroup.models));
        for ii = 1:length(modelGroup.models)
            if modelGroup.models(ii).valid
                contextsStart{ii} = modelGroup.models(ii).forecastOutput.context{1};
            end
        end
    elseif isa(modelGroup,'nb_model_update_vintages')
        contextsStart = cell(1,length(modelGroup));
        if fromResults
            for ii = 1:length(modelGroup)
                if modelGroup(ii).valid
                    if isa(modelGroup(ii),'nb_calculate_vintages')
                        contextsStart{ii} = modelGroup(ii).results.data.dataNames{1};
                    elseif isa(modelGroup(ii),'nb_model_vintages')
                        contextsStart{ii} = modelGroup(ii).results.context{1};
                    else
                        error([mfilename ':: Cannot fetch contexts from objects of class ' class(modelGroup(ii)) '.'])
                    end
                end
            end
        else
            for ii = 1:length(modelGroup)
                if isa(modelGroup(ii),'nb_calculate_vintages')
                    error([mfilename ':: Cannot fetch contexts from the forecastOutput property of objects of class ' class(modelGroup(ii)) '.'])
                end
                if modelGroup(ii).valid
                    contextsStart{ii} = modelGroup(ii).forecastOutput.context{1};
                end
            end
        end
    else
        error([mfilename ':: The modelGroup cannot be of class ' class(modelGroup) '.'])
    end

end
