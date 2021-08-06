function distributionMenuCallback(gui, ~, ~)
% Syntax:
%
% distributionMenuCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    selectedType = nb_getUIControlValue(gui.distributionMenu);    
    if strcmp(selectedType, 'kernel')
        gui.setPercentiles();
    else
        try
            set(gui.currentDistribution, 'type', selectedType);
        catch Err
            nb_errorWindow(Err.message);
        end
    end
    
    gui.addToHistory();
    gui.updateGUI();
    gui.set('incrementMode', 'off');
    
end
