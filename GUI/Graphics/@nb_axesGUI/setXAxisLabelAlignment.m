function setXAxisLabelAlignment(gui,hObject,~)
% Syntax:
%
% setXAxisLabelAlignment(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get the value selected
    index   = get(hObject,'value');
    strs    = get(hObject,'string');
    loc     = strs{index};

    % Set the plotter object
    gui.plotter.xTickLabelAlignment = loc;

    % Udate the graph
    notify(gui,'changedGraph');

end
