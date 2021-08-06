function selectScatterMarker(gui,hObject,~)
% Syntax:
%
% selectScatterMarker(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when changing the marker type
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string = get(gui.popupmenu1,'string');
    index  = get(gui.popupmenu1,'value');
    group  = string{index};

    % Get selected line style
    markers = get(hObject,'string');   
    index   = get(hObject,'value');
    marker  = markers{index};

    % Update the graph object
    ind = find(strcmp(group,plotterT.markers),1,'last'); 
    if isempty(ind)
        plotterT.markers = [plotterT.markers,group,marker];
    else
        plotterT.markers{ind + 1} = marker;
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
