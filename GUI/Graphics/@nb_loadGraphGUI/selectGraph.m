function selectGraph(gui,~,~)
% Syntax:
%
% selectGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected dataset
    index     = get(gui.listBox,'Value');
    string    = get(gui.listBox,'String');
    graphName = string{index};

    if isempty(graphName)
        close(gui.fig);
        return
    end

    % Get dataset
    appGraphs = gui.parent.graphs;
    plotterT  = appGraphs.(graphName);

    % Make copy of the graph object
    gui.plotter     = copy(plotterT);
    gui.plotterName = graphName;

    % Close window
    close(gui.fig);
    
    % Notify listeners
    notify(gui,'loadObjectFinished');

end
