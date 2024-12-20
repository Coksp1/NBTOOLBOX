function rename(gui,hObject,~)
% Syntax:
%
% rename(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));
    
    % Save the loaded graph object with a new name
    savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
    addlistener(savegui,'saveNameSelected',@gui.notifyListeners);

end
