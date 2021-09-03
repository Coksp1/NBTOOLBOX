function deleteVariable(gui,~,~)
% Syntax:
%
% deleteVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open dialog box to delete variables.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    methodgui = nb_deleteVariablesGUI(gui.parent,gui.data,'variables');
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);

end