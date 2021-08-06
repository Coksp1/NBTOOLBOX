function emptyObject = addEmptyGraph(gui)
% Syntax:
%
% addEmptyGraph(gui)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create an empty graph object
    switch class(gui.plotterAdv.plotter)
        case 'nb_graph_ts'
            emptyObject = nb_graph_ts();
        case 'nb_graph_cs'
            emptyObject = nb_graph_cs();
        case 'nb_graph_data'
            emptyObject = nb_graph_data();
    end
    setSpecial(emptyObject,'fontUnits','normalized');
    emptyObject.parent = gui.parent;
    if isa(gui.parent,'nb_GUI')
        setSpecial(emptyObject,'localVariables',gui.parent.settings.localVariables);
    end

    % Apply default settings
    applyDefault(gui.parent,emptyObject,gui.template);
    
end
