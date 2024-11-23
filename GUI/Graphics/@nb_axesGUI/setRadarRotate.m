function setRadarRotate(gui,hObject,~)
% Syntax:
%
% setRadarRotate(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        nb_errorWindow('The rotation of the radar must be a number (in degrees).')
        return
    end
    
    % Assign graph object
    plotter = gui.plotter;
    plotter.radarRotate = value;
    
    % Udate the graph
    notify(gui,'changedGraph');
    
end
