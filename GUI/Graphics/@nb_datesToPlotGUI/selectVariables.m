function selectVariables(gui,hObject,~)
% Syntax:
%
% selectVariables(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get type
    string = get(hObject,'string');
    index  = get(hObject,'value');
    vars   = string(index)';
    
    % Set property
    plotterT.variablesToPlot = vars;  

    % Notify listeners
    notify(gui,'changedGraph');

end
