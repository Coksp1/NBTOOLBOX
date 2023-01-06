function update(gui,~,~)
% Syntax:
%
% update(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update the data of the graphs of the package
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be updated.')
        return
    end

    update(gui.package,1);
    
    % The package has been changed, and the updated version can be saved
    gui.changed = 1;
    
    % Also update all the graph objects saved in the GUI by copying to
    % memory
    pack        = gui.package.graphs;
    identifiers = gui.package.identifiers;
    appGraphs   = gui.parent.graphs;
    for hh = 1:size(pack,2)     
        saveName             = identifiers{hh};
        appGraphs.(saveName) = copy(pack{hh}); 
    end
    gui.parent.graphs = appGraphs;

end
