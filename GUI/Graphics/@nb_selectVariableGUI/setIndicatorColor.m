function setIndicatorColor(gui,hObject,~)
% Syntax:
%
% setIndicatorColor(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select color of indicator callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get selected color
    endc  = nb_getGUIColorList(gui,parent);
    index = get(hObject,'value');
    color = endc{index};

    % Update the graph object
    gui.plotter.candleIndicatorColor = color;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
