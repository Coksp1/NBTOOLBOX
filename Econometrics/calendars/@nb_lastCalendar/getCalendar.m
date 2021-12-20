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
            calendar{ii} = modelGroup.models(ii).forecastOutput.context(end);
        end
    elseif isa(modelGroup,'nb_model_update_vintages')
        calendar = cell(1,length(modelGroup));
        if fromResults
            for ii = 1:length(modelGroup)
                if isa(modelGroup(ii),'nb_calculate_vintages')
                    calendar{ii} = modelGroup(ii).results.data.dataNames(end);
                elseif isa(modelGroup(ii),'nb_model_vintages')
                    calendar{ii} = modelGroup(ii).results.context(end);
                else
                    error([mfilename ':: Cannot fetch contexts from objects of class ' class(modelGroup(ii)) '.'])
                end
            end
        else
            for ii = 1:length(modelGroup)
                if isa(modelGroup(ii),'nb_calculate_vintages')
                    error([mfilename ':: Cannot fetch contexts from the forecastOutput property of objects of class ' class(modelGroup(ii)) '.'])
                end
                calendar{ii} = modelGroup(ii).forecastOutput.context(end);
            end
        end
    elseif iscellstr(modelGroup)
        calendar = {modelGroup(end)};    
    else
        error([mfilename ':: The modelGroup input cannot be of class ' class(modelGroup) '.'])
    end
    for ii = 1:size(calendar,2)
        % Secure the date format 'yyyymmdd'
        calendar{ii} = cellfun(@(x)x(1:8),calendar{ii},'uniformOutput',false);
    end
    calendar = unique([calendar{:}])';
    calendar = char(calendar);
    calendar = str2num(calendar); %#ok<ST2NM>
    calendar = nb_calendar.shrinkCalendar(calendar,start,finish);
     
end
