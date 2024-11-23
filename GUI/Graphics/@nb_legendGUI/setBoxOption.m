function setBoxOption(gui,hObject,~)
% Syntax:
%
% setBoxOption(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set box option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legBox = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
