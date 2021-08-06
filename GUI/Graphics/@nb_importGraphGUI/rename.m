function rename(gui,hObject,~)
% Syntax:
%
% rename(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));
    
    % Save the loaded graph object with a new name
    savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
    addlistener(savegui,'saveNameSelected',@gui.notifyListeners);
    
end
