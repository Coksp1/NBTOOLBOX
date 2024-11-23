function saveObjectCallback(gui,hObject,~)
% Syntax:
%
% saveObjectCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when graph is saved to the main GUI.
%
% Input:
%
% - hObject : An nb_saveAsGraphGUI object. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get selected save name and assign the graph window (The new
    % name will appear in the figure name)
    gui.plotterName = hObject.saveName;
    gui.changed     = 0;
    
    % If the graph is included in a package we sync it
    % (could have dropped to copy the object, but that
    % has other unwanted consequences)
    syncPackage(gui.parent,gui.plotterName);
                    
end
