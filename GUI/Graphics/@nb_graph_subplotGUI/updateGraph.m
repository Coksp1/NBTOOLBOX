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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    graph(gui.plotter);
    gui.changed = 1;

end
