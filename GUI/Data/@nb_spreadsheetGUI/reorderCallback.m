function reorderCallback(gui,hObject,~)
% Syntax:
%
% reorderCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Reorder variables/types/datasets in a GUI.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    type      = get(hObject,'label');
    methodgui = nb_reorderPropertyGUI(gui.parent,gui.data,type);
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);
    
end
