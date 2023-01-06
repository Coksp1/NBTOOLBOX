function calculateCallback(gui, ~, ~, window)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in 
% the GUI
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the number of periods to expand by
    greedy = get(gui.components.greedy,'value');
    try
        gui.data = easterDummy(gui.data,greedy);
    catch Err
        nb_errorWindow('An error occurred while adding the easter dummy:',Err);
        return
    end
        
    % Close window
    close(window);
    
    % Notify listeners
    notify(gui,'methodFinished');

end
