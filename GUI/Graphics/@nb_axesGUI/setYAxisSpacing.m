function setYAxisSpacing(gui,hObject,~,side)
% Syntax:
%
% setYAxisSpacing(gui,hObject,event,side)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the value selected
    strs = get(hObject,'string');
    if isempty(strs)
        sp = [];
    else
        sp = str2double(strs);
    end

    if isnan(sp)
        nb_errorWindow(['The Y-Axis Spacing (' side ') must be an integer.'])
        return
    elseif sp == 0
        sp = 1;
    end
    
    % Set the plotter object
    if strcmpi(side,'left')
        gui.plotter.ySpacing = sp;
    else
        gui.plotter.ySpacingRight = sp;
    end

    % Udate the graph
    notify(gui,'changedGraph');

end
