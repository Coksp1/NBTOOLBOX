function renamePage(gui,~,~)
% Syntax:
%
% renamePage(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open dialog box to rename pages of dataset.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    methodgui = nb_renameGUI(gui.parent,gui.data,'page');
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);
    
end
