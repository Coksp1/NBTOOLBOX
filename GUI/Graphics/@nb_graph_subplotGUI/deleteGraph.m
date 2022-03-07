function deleteGraph(gui,~,~,subPlotter)
% Syntax:
%
% deleteGraph(gui,hObject,event,subPlotter)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Remove the graph from the panel.
    plotterT = gui.plotter;
    plotterT.remove(subPlotter);
    
    % Delete axes of the deleted graph object
    if isa(subPlotter,'nb_graph_adv')
        subPlotter = subPlotter.plotter;
    end
    ax = get(subPlotter,'axesHandle');
    ax.deleteOption = 'all';
    delete(ax);
    
    % Update the graph
    graph(plotterT);
    gui.changed = 1;

end
