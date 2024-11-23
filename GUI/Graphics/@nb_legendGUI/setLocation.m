function setLocation(gui,hObject,~)
% Syntax:
%
% setLocation(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set location option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legLocation = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
