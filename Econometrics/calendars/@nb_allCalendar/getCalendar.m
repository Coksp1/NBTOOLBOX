function calendar = getCalendar(~,start,finish,modelGroup,doRecursive,fromResults) 

    if nargin < 6
        fromResults = false;
    end

    if isscalar(modelGroup) && isa(modelGroup,'nb_model_group_vintages') && doRecursive
        if fromResults
            error([mfilename ':: Cannot fetch contexts from objects of class nb_model_group_vintages.'])
        end
        calendar = cell(1,length(modelGroup.models));
        for ii = 1:length(modelGroup.models)
            calendar{ii} = modelGroup.models(ii).forecastOutput.context;
        end
    elseif isa(modelGroup,'nb_model_update_vintages')
        calendar = cell(1,length(modelGroup));
        if fromResults
            for ii = 1:length(modelGroup)
                if isa(modelGroup(ii),'nb_calculate_vintages')
                    calendar{ii} = modelGroup(ii).results.data.dataNames;
                elseif isa(modelGroup(ii),'nb_model_vintages')
                    calendar{ii} = modelGroup(ii).results.context;
                else
                    error([mfilename ':: Cannot fetch contexts from objects of class ' class(modelGroup(ii)) '.'])
                end
            end
        else
            for ii = 1:length(modelGroup)
                if isa(modelGroup(ii),'nb_calculate_vintages')
                    error([mfilename ':: Cannot fetch contexts from the forecastOutput property of objects of class ' class(modelGroup(ii)) '.'])
                end
                calendar{ii} = modelGroup(ii).forecastOutput.context;
            end
        end
    else
        error([mfilename ':: The modelGroup cannot be of class ' class(modelGroup) '.'])
    end
    calendar = unique([calendar{:}])';
    calendar = char(calendar);
    calendar = str2num(calendar); %#ok<ST2NM>
    calendar = nb_calendar.shrinkCalendar(calendar,start,finish);
     
end
