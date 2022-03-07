function currentDistributionMenuCallback(gui, ~, ~)
% Syntax:
%
% currentDistributionMenuCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    selectedIndex = get(gui.currentDistributionMenu, 'value');
    gui.currentDistributionIndex = selectedIndex; 
    gui.updateGUI();
    
end
