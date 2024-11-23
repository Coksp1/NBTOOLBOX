function convertCallback(gui,hObject,~)
% Syntax:
%
% convertCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the added string
    format = nb_getSelectedFromPop(gui.pop1);
    strip  = nb_getSelectedFromPop(gui.pop2);
  
    % Evaluate the expression
    try
        gui.data = tonb_cs(gui.data,format,strip);
    catch Err
        nb_errorWindow('Could not convert time-series object.', Err)
        return
    end
    
    % Close window
    close(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end
