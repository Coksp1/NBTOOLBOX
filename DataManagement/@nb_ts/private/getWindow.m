function [startDateWin,endDateWin,variablesWin,startInd,endInd,variablesInd,pages] = getWindow(obj,startDateWin,endDateWin,variablesWin,pages)
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Which dates to keep
    if ~isempty(startDateWin)

        startDateWin = nb_date.toDate(startDateWin,obj.frequency);
        startInd = (startDateWin - obj.startDate) + 1;
        if startInd < 1 || startInd > obj.numberOfObservations

            error([mfilename ':: beginning of window (''' startDateWin.toString ''') starts before the start date (''' obj.startDate.toString() ''') '...
                             'or starts after the end date (''' obj.endDate.toString ''') of the data '])

        end

    else
        startInd     = 1;
        startDateWin = obj.startDate;
    end

    if ~isempty(endDateWin)

        endDateWin   = nb_date.toDate(endDateWin,  obj.frequency);
        endInd = (endDateWin - obj.startDate) + 1;
        if endInd < 1 || endInd > obj.numberOfObservations

            error([mfilename ':: end of window (''' endDateWin.toString ''') ends after the end date (''' obj.endDate.toString ''') or '...
                             'ends before the start date (''' obj.startDate.toString() ''') of the data '])

        end

    else
        endInd     = obj.numberOfObservations;
        endDateWin = obj.endDate;
    end

    % Remove all other variables not given in the cellstr variables
    if ~isempty(variablesWin)

        variablesWin = cellstr(variablesWin);
        variablesInd = zeros(1,max(size(obj.variables)));
        for ii = 1:max(size(variablesWin))
            var_id = strcmp(variablesWin{ii},obj.variables);
            variablesInd = variablesInd + var_id;
            if sum(var_id)==0
                warning('nb_ts:window:VariableNotFound',[mfilename ':: Variable ''' variablesWin{ii} ''' not found.']) 
            end
        end

        variablesInd = logical(variablesInd);

    else

        variablesWin = obj.variables;
        variablesInd = true(1,size(obj.variables,2)); % To ensure that we keep all variables

    end

    % Which pages to keep
    if isempty(pages)
        pages = 1:obj.numberOfDatasets;
    else
        if isnumeric(pages)
            m = max(pages);
            if m > obj.numberOfDatasets
                error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to reach the dataset ' int2str(m) ', which is not possible.'])
            end
        elseif ischar(pages)
            pages = strcmp(pages,obj.dataNames);
        else
            pages = nb_ts.locateVariables(pages,obj.dataNames);
        end
    end

end
