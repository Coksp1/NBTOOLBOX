function setColumns(gui,hObject,~)
% Syntax:
%
% setColumns(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set columns option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = str2double(string{index});
    
    % Assign graph object
    gui.plotter.legColumns = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
