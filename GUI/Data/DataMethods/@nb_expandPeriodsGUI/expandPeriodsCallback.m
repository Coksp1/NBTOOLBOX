function expandPeriodsCallback(gui, ~, ~, window)
% Syntax:
%
% expandPeriodsCallback(gui,hObject,event, window)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the number of periods to expand by
    numOfPeriods = get(gui.numOfPeriodsBox,'string');
    numOfPeriods = str2double(numOfPeriods);
    
    % Get the type of the appended data
    index    = get(gui.typePop,'value');
    type = gui.typePopOptions{index};

    try
        gui.data = gui.data.expandPeriods(numOfPeriods, type);
    catch Err
        % TODO: Check for specific errors
        nb_errorWindow(Err.message);
        return
    end
        
    % Close window
    close(window);
    
    % Notify listeners
    notify(gui,'methodFinished');

end
