function interpolateCallback(gui,hObject,~)
% Syntax:
%
% interpolateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the new start date
    string = get(gui.popup,'string');
    index  = get(gui.popup,'value');
    method = string{index};
    
    % Evaluate the expression  
    gui.data = gui.data.interpolate(method);
    
    % Close window
    close(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end
