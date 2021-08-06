function updateGraph(gui,~,~)
% Syntax:
%
% updateGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update the graph object. E.g. because of updated local 
% variables
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    graph(gui.plotter);
    gui.changed = 1;

end
