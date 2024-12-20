function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Delete the former menus
    delete(get(gui.datasetMenu,'children'));
    delete(get(gui.statisticsMenu,'children'));
    
    % Read the ui menus
    addMenuComponents(gui);

end
