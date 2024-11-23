function setAxesGrid(gui,hObject,~)
% Syntax:
%
% setAxesGrid(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the value selected
    index   = get(hObject,'value');
    strs    = get(hObject,'string');
    gri     = strs{index};

    % Set the plotter object
    gui.plotter.grid = gri;

    % Udate the graph
    notify(gui,'changedGraph');
    
end
