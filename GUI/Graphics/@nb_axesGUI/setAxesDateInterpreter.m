function setAxesDateInterpreter(gui,hObject,~)
% Syntax:
%
% setAxesDateInterpreter(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get the value selected
    index  = get(hObject,'value');
    strs   = get(hObject,'string');
    dI     = strs{index};

    % Set the plotter object
    gui.plotter.set('dateInterpreter',dI);

    % Udate the graph
    notify(gui,'changedGraph');

end
