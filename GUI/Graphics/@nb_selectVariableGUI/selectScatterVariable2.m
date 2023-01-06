function selectScatterVariable2(gui,hObject,~)
% Syntax:
%
% selectScatterVariable2(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get selected variable
    selected = nb_getUIControlValue(hObject);
    group    = nb_getUIControlValue(gui.popupmenu1); 
    
    % Get the scatter groupes
    switch lower(gui.scatterSide)
        case 'left'
            ind             = find(strcmpi(group,gui.plotter.scatterDates(1:2:end)),1);
            scaVars         = gui.plotter.scatterVariables;
            scaVars{ind}{2} = selected;  
            gui.plotter.set('scatterVariables', scaVars);
        case 'right'
            ind             = find(strcmpi(group,gui.plotter.scatterDatesRight(1:2:end)),1);
            scaVars         = gui.plotter.scatterVariablesRight;
            scaVars{ind}{2} = selected;  
            gui.plotter.set('scatterVariablesRight', scaVars);
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
