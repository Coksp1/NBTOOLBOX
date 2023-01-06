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

    % Get selected color
    endc   = nb_getGUIColorList(gui,parent);
    string = get(hObject,'string');
    index  = get(hObject,'value');
    if strcmpi(string{index},'none')
        color = string{index};
    else
        color  = endc{index};
    end

    % Update the graph object
    plotterT.pieEdgeColor = color;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
