function setYAxisDir(gui,hObject,~,side)
% Syntax:
%
% setYAxisDir(gui,hObject,event,side)
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
    ydir    = strs{index};

    % Set the plotter object
    if strcmpi(side,'left')
        gui.plotter.yDir = ydir;
    else
        gui.plotter.yDirRight = ydir;
    end

    % Udate the graph
    notify(gui,'changedGraph');

end
