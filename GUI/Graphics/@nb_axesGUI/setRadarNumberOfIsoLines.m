function setRadarNumberOfIsoLines(gui,hObject,~)
% Syntax:
%
% setRadarNumberOfIsoLines(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = round(str2double(string));
    
    if isnan(value)
        nb_errorWindow('The number of iso-lines of the radar must be a number greater then 0.')
        return
    elseif value <= 0
        nb_errorWindow('The number of iso-lines of the radar must be a number greater then 0.')
        return
    end
    
    % Assign graph object
    plotter = gui.plotter;
    plotter.radarNumberOfIsoLines = value;
    
    % Udate the graph
    notify(gui,'changedGraph');
    
end
