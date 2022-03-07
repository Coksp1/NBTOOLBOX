function selectScatterVariable1(gui,hObject,~)
% Syntax:
%
% selectScatterVariable1(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback when scatter variable 1 is changed    
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected variable
    selected = nb_getUIControlValue(hObject);
    group    = nb_getUIControlValue(gui.popupmenu1);      
    
    % Get the scatter groupes
    switch lower(gui.scatterSide)
        case 'left'
            ind             = find(strcmpi(group,gui.plotter.scatterDates(1:2:end)),1);
            scaVars         = gui.plotter.scatterVariables;
            scaVars{ind}{1} = selected;  
            gui.plotter.set('scatterVariables', scaVars);
        case 'right'
            ind             = find(strcmpi(group,gui.plotter.scatterDatesRight(1:2:end)),1);
            scaVars         = gui.plotter.scatterVariablesRight;
            scaVars{ind}{1} = selected;  
            gui.plotter.set('scatterVariablesRight', scaVars);
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
