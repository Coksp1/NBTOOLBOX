function setAxesFontWeight(gui,hObject,~)
% Syntax:
%
% setAxesFontWeight(gui,hObject,event)
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
    afw     = strs{index};

    % Set the plotter object
    gui.plotter.axesFontWeight = afw;

    % Udate the graph
    notify(gui,'changedGraph');

end
