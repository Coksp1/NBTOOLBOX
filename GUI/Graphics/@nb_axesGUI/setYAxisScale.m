function setYAxisScale(gui,hObject,~,side)
% Syntax:
%
% setYAxisScale(gui,hObject,event,side)
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
    scale   = strs{index};

    % Set the plotter object
    if strcmpi(side,'left')
        gui.plotter.yScale = scale;
    else
        gui.plotter.yScaleRight = scale;
    end

    % Udate the graph
    notify(gui,'changedGraph');

end
