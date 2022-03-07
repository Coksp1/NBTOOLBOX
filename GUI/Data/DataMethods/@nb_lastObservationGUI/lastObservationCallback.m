function lastObservationCallback(gui,~,~,window)
% Syntax:
%
% lastObservationCallback(gui,hObject,event,window)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the added string
    string = get(gui.editbox,'string');

    number = str2double(string);
    if ~nb_iswholenumber(number)
        nb_errorWindow('Please type an integer')
        return
    end
    
    try
        gui.data = gui.data.lastObservation(number);
    catch Err
        if strcmp(Err.identifier, 'nb_ts:lastObservation:outOfBounds')
            nb_errorWindow('Number out of bounds');
        else
            nb_errorWindow(Err.message);
        end
        return
    end
        
    % Close window
    close(window);
    
    % Notify listeners
    notify(gui,'methodFinished');

end
