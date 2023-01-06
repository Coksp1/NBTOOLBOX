function renamePackage(gui,~,~)
% Syntax:
%
% renamePackage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved.')
        return
    end
    
    gui.oldSaveName = gui.packageName;
    
    if isempty(gui.oldSaveName)
        nb_errorWindow('Cannot rename an object without a name');
        return
    end
    
    savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
    
    addlistener(savegui,'saveNameSelected',@gui.deleteOldPackage);
    addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);

end
