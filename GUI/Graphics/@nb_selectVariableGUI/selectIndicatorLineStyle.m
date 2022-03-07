function selectIndicatorLineStyle(gui,hObject,~)
% Syntax:
%
% selectIndicatorLineStyle(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select line style of indicator callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected line style
    lineStyles = get(hObject,'string');
    index      = get(hObject,'value');
    lineS      = lineStyles{index};

    % Update the graph object
    plotterT.candleIndicatorLineStyle = lineS;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
