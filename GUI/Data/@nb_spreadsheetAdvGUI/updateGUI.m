function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Delete the former menus
    delete(get(gui.datasetMenu,'children'));
    delete(get(gui.statisticsMenu,'children'));
    
    % Read the ui menus
    addMenuComponents(gui);

end
