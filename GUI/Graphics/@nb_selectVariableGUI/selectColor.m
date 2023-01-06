function selectColor(gui,hObject,~)
% Syntax:
%
% selectColor(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select color
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;

    % Get selected variable
    if strcmpi(plotterT.plotType,'candle')
        var = 'candle';
    else
        string  = get(gui.popupmenu1,'string');
        index   = get(gui.popupmenu1,'value');
        var     = string{index};
    end

    % Get selected color
    endc  = nb_getGUIColorList(gui,parent);
    index = get(hObject,'value');
    color = endc{index};

    % Update the graph object
    ind = find(strcmp(var,plotterT.colors),1,'last');
    if isempty(ind)
        plotterT.colors = [plotterT.colors,{var},{color}];
    else
        plotterT.colors{ind + 1} = color;
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
