function setReorder(gui,hObject,~)
% Syntax:
%
% setReorder(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set reorder option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legReorder = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
