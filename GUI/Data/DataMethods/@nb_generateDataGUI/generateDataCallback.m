function generateDataCallback(gui, ~, ~)
% Syntax:
%
% generateDataCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Generate data
    switch class(gui.data)
        case 'nb_ts'
            createDataset_ts(gui);
        case 'nb_data'
            createDataset_data(gui);
        case 'nb_cs'
            createDataset_cs(gui);
        case 'nb_cell'
            createDataset_cell(gui);
    end
        
    % Close window
    close(gui.figureHandle);
    
    % Notify listeners
    notify(gui, 'methodFinished');
end

function createDataset_ts(gui)
    start = get(gui.startBox,'string');
    try
        start = nb_date.date2freq(start);
    catch %#ok<CTCH>
        nb_errorWindow(['Unsupported date format ' start '.'])
        return
    end
    
    numOfObs = round(str2double(get(gui.numOfObsBox,'string')));
    if isnan(numOfObs)
         nb_errorWindow('Number of observations must be set to a number.')
        return
    else
        if numOfObs > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 observations');
            return
        end
    end
    
    numOfVars = round(str2double(get(gui.numOfVarsBox,'string')));
    if isnan(numOfVars)
         nb_errorWindow('Number of variables must be set to a number.')
        return    
    else
        if numOfVars > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 variables');
            return
        end
    end
    
    numOfPages = round(str2double(get(gui.numOfPagesBox,'string')));
    if isnan(numOfPages)
         nb_errorWindow('Number of pages must be set to a number.')
        return    
    else
        if numOfPages > 100
            nb_errorWindow('Cannot make random datasets with more than 100 pages');
            return
        end
    end
    
    % Construct random nb_ts object
    gui.data = nb_ts.rand(start, numOfObs, numOfVars, numOfPages, gui.distribution);
end

function createDataset_data(gui)

    start = round(str2double(get(gui.startBox,'string')));
    if isnan(start)
        nb_errorWindow(['Unsupported start obsservation ' startS '.'])
        return
    end
    
    numOfObs = round(str2double(get(gui.numOfObsBox,'string')));
    if isnan(numOfObs)
         nb_errorWindow('Number of observations must be set to a number.')
        return
    else
        if numOfObs > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 observations');
            return
        end
    end
    
    numOfVars = round(str2double(get(gui.numOfVarsBox,'string')));
    if isnan(numOfVars)
         nb_errorWindow('Number of variables must be set to a number.')
        return    
    else
        if numOfVars > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 variables');
            return
        end
    end
    
    numOfPages = round(str2double(get(gui.numOfPagesBox,'string')));
    if isnan(numOfPages)
         nb_errorWindow('Number of pages must be set to a number.')
        return    
    else
        if numOfPages > 100
            nb_errorWindow('Cannot make random datasets with more than 100 pages');
            return
        end
    end
    
    % Construct random nb_ts object
    gui.data = nb_data.rand(start, numOfObs, numOfVars, numOfPages, gui.distribution);
end

function createDataset_cs(gui)
    numOfTypes = round(str2double(get(gui.numOfTypesBox,'string')));
    if isnan(numOfTypes)
        nb_errorWindow('Number of types must be set to a number.')
        return
    else
        if numOfTypes > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 types');
            return
        end
    end
    
    numOfVars = round(str2double(get(gui.numOfVarsBox,'string')));
    if isnan(numOfVars)
        nb_errorWindow('Number of variables must be set to a number.')
        return
    else
        if numOfVars > 20000
            nb_errorWindow('Cannot make random datasets with more than 20 000 variables');
            return
        end
    end
    
    numOfPages = round(str2double(get(gui.numOfPagesBox,'string')));
    if isnan(numOfPages)
        nb_errorWindow('Number of pages must be set to a number.')
        return
    else
        if numOfPages > 100
            nb_errorWindow('Cannot make random datasets with more than 100 pages');
            return
        end
    end
    
    % Construct random nb_cs object
    gui.data = nb_cs.rand(numOfTypes, numOfVars, numOfPages, gui.distribution);
end

function createDataset_cell(gui)
    numOfTypes = round(str2double(get(gui.numOfTypesBox,'string')));
    if isnan(numOfTypes)
        nb_errorWindow('Number of rows must be set to a number.')
        return
    else
        if numOfTypes > 2000
            nb_errorWindow('Cannot make random datasets with more than 2 000 rows');
            return
        end
    end
    
    numOfVars = round(str2double(get(gui.numOfVarsBox,'string')));
    if isnan(numOfVars)
        nb_errorWindow('Number of columns must be set to a number.')
        return
    else
        if numOfVars > 2000
            nb_errorWindow('Cannot make random datasets with more than 2 000 columns');
            return
        end
    end
    
    numOfPages = round(str2double(get(gui.numOfPagesBox,'string')));
    if isnan(numOfPages)
        nb_errorWindow('Number of pages must be set to a number.')
        return
    else
        if numOfPages > 100
            nb_errorWindow('Cannot make random datasets with more than 100 pages');
            return
        end
    end
    
    % Construct random nb_cs object
    gui.data = nb_cell.rand(numOfTypes, numOfVars, numOfPages, gui.distribution);
end
