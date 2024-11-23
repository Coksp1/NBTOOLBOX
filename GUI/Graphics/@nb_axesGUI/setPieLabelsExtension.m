function setPieLabelsExtension(gui,hObject,~)
% Syntax:
%
% setPieLabelsExtension(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    value = get(hObject, 'string');
    
    % Assign graph object
    gui.plotter.pieLabelsExtension = value;
    
    % Update the graph
    notify(gui,'changedGraph');
end
