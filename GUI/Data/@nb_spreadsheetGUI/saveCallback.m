function saveCallback(gui,hObject,~)
% Syntax:
%
% saveCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when dataset is saved to 
% the main GUI.
% 
% Input:
%
% - hObject : An nb_importDataGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected save name and assign the spreadsheet (The new
    % name will appear in the figure name)
    gui.dataName = hObject.saveName;
    gui.changed  = 0;
    notify(gui,'savedData');
    
end
