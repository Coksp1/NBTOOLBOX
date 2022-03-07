function setXAxisTickLocation(gui,hObject,event)
% Syntax:
%
% setXAxisTickLocation(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the value selected
    index   = get(hObject,'value');
    strs    = get(hObject,'string');
    loc     = strs{index};

    % Set the plotter object
    gui.plotter.xTickLocation = loc;

    % Udate the graph
    notify(gui,'changedGraph');

end
