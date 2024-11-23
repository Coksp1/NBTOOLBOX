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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get variable
    string = get(gui.varpopup,'string');
    index  = get(gui.varpopup,'value');
    var    = string{index};
    
    % Get selected string
    string        = get(hObject,'string');
    index         = get(hObject,'value');
    selectedDates = string(index);
   
    % Set property
    nanVars               = plotterT.nanVariables;
    index                 = find(strcmpi(var,nanVars(1:2:end)),1);
    nanVars{index*2}{2}   = selectedDates;
    plotterT.nanVariables = nanVars;  

    % Notify listeners
    notify(gui,'changedGraph');

end
