function setRadarScale(gui,hObject,~,index)
% Syntax:
%
% setRadarScale(gui,hObject,event,index)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get the value selected
    strs    = get(hObject,'string');
    value   = str2double(strs);

    if isnan(value)
        nb_errorWindow(['The radar scale(' int2str(index) ') must be a number.'])
        return
    end
        
    % Set the plotter object
    gui.plotter.radarScale(index) = value;

    % Udate the graph
    notify(gui,'changedGraph');

end
