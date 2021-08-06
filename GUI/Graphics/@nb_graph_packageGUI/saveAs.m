function saveAs(gui,~,~)
% Syntax:
%
% saveAs(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save as
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved.')
        return
    end
    
    savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
    addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);

end
