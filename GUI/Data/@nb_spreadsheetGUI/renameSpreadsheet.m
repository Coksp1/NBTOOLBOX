function renameSpreadsheet(gui,~,~)
% Syntax:
%
% renameSpreadsheet(gui,hObject,event)
%
% Description:
%
% Part of DAG. Rename spreadsheet
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data to rename.')
        return
    end
    gui.oldSaveName = gui.dataName;
    if isempty(gui.oldSaveName)
        nb_errorWindow('Cannot rename a dataset that doesn''t have save name (i.e. has not been saved before).')
        return
    end
    savegui = nb_saveAsDataGUI(gui.parent,gui.data);
    addlistener(savegui,'saveNameSelected',@gui.deleteOldFile);
    addlistener(savegui,'saveNameSelected',@gui.saveCallback);
    
end

