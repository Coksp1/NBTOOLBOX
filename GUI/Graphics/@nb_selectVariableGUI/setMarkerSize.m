function setMarkerSize(gui,hObject,~)
% Syntax:
%
% setMarkerSize(gui,hObject,event)
%
% Description:
%
% Part of DAG. Called when marker size is changed by the user
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get selected marker size
    markerS = get(hObject,'string');
    markerS = str2double(markerS);
    if isnan(markerS)
        nb_errorWindow('The provided marker size must be a number.')
        return
    elseif markerS <= 0
        nb_errorWindow(['The marker size must be set to a number greater then 0. Is ' string '.'])
        return    
    end

    % Update the graph object
    gui.plotter.markerSize = markerS;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
