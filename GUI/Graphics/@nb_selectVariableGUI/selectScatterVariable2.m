function selectScatterVariable2(gui,hObject,~)
% Syntax:
%
% selectScatterVariable2(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen
            
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
