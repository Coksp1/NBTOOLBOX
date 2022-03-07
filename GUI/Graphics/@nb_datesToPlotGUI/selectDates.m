function selectDates(gui,hObject,~)
% Syntax:
%
% selectDates(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    
    % Get selected dates
    string        = get(hObject,'string');
    index         = get(hObject,'value');
    selectedDates = string(index)';
   
    % Update the datesToPlot property
    plotterT.datesToPlot = selectedDates;
    
    % Notify listeners
    notify(gui,'changedGraph');

end

