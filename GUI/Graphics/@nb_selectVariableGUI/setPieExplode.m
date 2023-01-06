function setPieExplode(gui,checkbox,~,variable)
% Syntax:
%
% setPieExplode(gui,hObject,event)
%
% Description:
%
% Part of DAG. Toggle pieExplode callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    isExploded = (get(checkbox, 'Value') == 1);
    
    % Update the graph object
    if isExploded
        % Add variable to pieExploded
        gui.plotter.pieExplode = [gui.plotter.pieExplode, variable];
    else
        % Remove variable from pieExploded
        indices  = strcmp(variable, gui.plotter.pieExplode);
        gui.plotter.pieExplode(indices) = [];
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
end
