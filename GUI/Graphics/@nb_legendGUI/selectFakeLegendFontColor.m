function selectFakeLegendFontColor(gui,hObject,~)
% Syntax:
%
% selectFakeLegendFontColor(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the current fake legend
    string = get(gui.popupmenu2,'string');
    index  = get(gui.popupmenu2,'value');
    fakeL  = string{index};
    
    % Locate the fake legend in the graph object
    plotterT = gui.plotter;
    parent   = plotterT.parent;
    fakeLs   = plotterT.fakeLegend;
    indF     = find(strcmp(fakeL,fakeLs),1,'last');
    options  = fakeLs{indF + 1};
    
    % Get color selected
    endc  = nb_getGUIColorList(gui,parent);
    index = get(hObject,'value');
    color = endc{index};
    
    % Assign changes
    ind = find(strcmpi('fontColor',options),1,'last');
    if isempty(ind)
        options = [options,'fontColor',color];
    else
        options{ind + 1} = color;
    end
    fakeLs{indF + 1} = options;
    
    % Update graph object
    plotterT.fakeLegend = fakeLs;
    
    % Notify listeners
    notify(gui,'changedGraph');
    
end
