function overwrite(gui,hObject,~)
% Syntax:
%
% overwrite(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the already stored data
    appGraphs = gui.parent.graphs;

    % Overwrite existing dataset
    appGraphs.(gui.name) = gui.plotter;

    % Assign it to the main GUI object so I can use it later. This will
    % also make it display in the list of the GUI, see nb_GUI.set.graphs
    gui.parent.graphs = appGraphs;

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));
    
    % Sync local variables of object and GUI
    notify(gui,'importingDone');

end
