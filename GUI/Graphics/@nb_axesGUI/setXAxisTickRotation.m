function setXAxisTickRotation(gui,hObject,~)
% Syntax:
%
% setXAxisTickRotation(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the value selected
    strs    = get(hObject,'string');
    if isempty(strs)
        sp = 0;
    else
        sp = round(str2double(strs));
    end

    if isnan(sp)
        nb_errorWindow('The X-Axis Rotation must be a number (in degrees). Positive angles cause counterclockwise rotation.')
        return
    elseif sp < 0
        sp = 0;
    end
    
    % Set the plotter object
    gui.plotter.xTickRotation = sp;

    % Udate the graph
    notify(gui,'changedGraph');

end
