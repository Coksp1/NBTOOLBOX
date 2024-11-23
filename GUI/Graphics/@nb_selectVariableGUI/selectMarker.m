function selectMarker(gui,hObject,~,type)
% Syntax:
%
% selectMarker(gui,hObject,event,type)
%
% Description:
%
% Part of DAG. Callback function called when changing the marker type
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');     

    % Get selected line style
    switch type
        
        case '1'
    
            var     = string{index};
            markers = get(hObject,'string');   
            index   = get(gui.popupmenu6,'value');
            marker  = markers{index};

        case '2'
            
            var     = [string{index},'(2)'];
            markers = get(hObject,'string');   
            index   = get(gui.popupmenu11,'value');
            marker  = markers{index};
            
    end

    % Update the graph object
    ind = find(strcmp(var,plotterT.markers),1,'last'); 
    if isempty(ind)
        if ~(strcmpi(marker,'none') && strcmpi(type,'1'))
            plotterT.markers = [plotterT.markers,var,marker];
        end
    else
        if strcmpi(marker,'none') && strcmpi(type,'1')
            plotterT.markers = [plotterT.markers(1:ind - 1),plotterT.markers(ind + 2:end)];
        else
            plotterT.markers{ind + 1} = marker;
        end
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
