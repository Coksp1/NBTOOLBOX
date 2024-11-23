function renameVariable(gui,~,~)
% Syntax:
%
% renameVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open dialog box to rename variables
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    methodgui = nb_renameGUI(gui.parent,gui.data,'variable');
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);

end
