function setLocation(gui,hObject,~)
% Syntax:
%
% setLocation(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set location option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legLocation = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
