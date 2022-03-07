function selectIndicatorMarker(gui,hObject,~)
% Syntax:
%
% selectIndicatorMarker(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select marker of indicator callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected marker
    markers = get(hObject,'string');   
    index   = get(hObject,'value');
    marker  = markers{index};

    % Update the graph object
    plotterT.candleMarker = marker;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
