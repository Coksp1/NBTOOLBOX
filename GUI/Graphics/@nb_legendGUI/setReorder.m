function setReorder(gui,hObject,~)
% Syntax:
%
% setReorder(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set reorder option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legReorder = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
