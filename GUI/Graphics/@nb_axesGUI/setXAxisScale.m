function setXAxisScale(gui,hObject,~)
% Syntax:
%
% setXAxisScale(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the value selected
    index   = get(hObject,'value');
    strs    = get(hObject,'string');
    scale   = strs{index};

    % Set the plotter object
    gui.plotter.xScale = scale;

    % Udate the graph
    notify(gui,'changedGraph');

end
