function saveObjectCallback(gui,hObject,~)
% Syntax:
%
% saveObjectCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when graph is saved to the main 
% GUI.
%
% Input:
%
% - hObject : An nb_saveAsPackageGUI object.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get selected save name and assign the graph window (The new
    % name will appear in the figure name)
    gui.packageName = hObject.saveName;
    gui.changed     = 0;
                      
end