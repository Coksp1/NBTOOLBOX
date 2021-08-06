function changeSelectedGraph(gui,~,~)
% Syntax:
%
% changeSelectedGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get selcted graph
    string   = get(gui.listbox,'string');
    index    = get(gui.listbox,'value');
    selected = string{index};

    % Get the graph object
    packageT  = gui.package;
    ind       = strcmp(selected,packageT.identifiers);
    tempGraph = packageT.graphs{ind};

    % Get the figure names
    figNameNor = tempGraph.figureNameNor;
    figNameEng = tempGraph.figureNameEng;
    
    % Assign the figure names to the edit boxes
    set(gui.editbox1,'string',figNameNor);
    set(gui.editbox2,'string',figNameEng);
    
end
