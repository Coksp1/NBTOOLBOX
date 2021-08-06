function setBoxOption(gui,hObject,~)
% Syntax:
%
% setBoxOption(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set box option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legBox = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
