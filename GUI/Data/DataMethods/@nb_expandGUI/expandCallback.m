function expandCallback(gui, ~, ~, window)
% Syntax:
%
% expandCallback(gui,hObject,event, window)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in the GUI
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the new window
    newStart = get(gui.startBox,'string');
    newEnd = get(gui.endBox,'string');
    
    % nb_data: Convert window values to doubles
    if isa(gui.data, 'nb_data')
        newStart = str2double(newStart);
        newEnd = str2double(newEnd);
    end
    
    % Get the type of the appended data
    index = get(gui.typePop,'value');
    type  = gui.typePopOptions{index};

    try
        gui.data = gui.data.expand(newStart, newEnd, type);
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
