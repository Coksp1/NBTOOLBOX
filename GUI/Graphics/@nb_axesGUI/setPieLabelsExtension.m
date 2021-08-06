function setPieLabelsExtension(gui,hObject,~)
% Syntax:
%
% setPieLabelsExtension(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    value = get(hObject, 'string');
    
    % Assign graph object
    gui.plotter.pieLabelsExtension = value;
    
    % Update the graph
    notify(gui,'changedGraph');
end
