function addEmptyGraph(gui,~,~)
% Syntax:
%
% addEmptyGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add a graph to the panel if it is not already filled to 
% the limit
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT       = gui.plotter;
    numberOfFitted = plotterT.subPlotSize(1)*plotterT.subPlotSize(2); 
    if length(plotterT.graphObjects) < numberOfFitted
        
        % Create an empty graph object
        emptyObject = nb_graph_ts();
        emptyObject = plotterT.add(emptyObject); % Here a copy is made so therefore I need to return the emptyObject
        setSpecial(emptyObject,'fontUnits','normalized');
        emptyObject.parent = gui.parent;
        if isa(gui.parent,'nb_GUI')
            setSpecial(emptyObject,'localVariables',gui.parent.settings.localVariables);
        end
        addContextMenu(gui,emptyObject);
        
    else
        nb_errorWindow(['The graph panel is already filled. '...
            'Cannot add graph object to panel. Go to Properties\General to set the subplot size.'])
        return
    end

    % Update the graph
    graph(plotterT);
    gui.changed = 1;

end
