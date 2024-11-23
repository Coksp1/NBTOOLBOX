function updateGraph(gui,~,~)
% Syntax:
%
% updateGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update the graph object. E.g. because of updated local 
% variables.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    plotter.graph();
    changedCallback(gui,[],[]);

end
