function createDummy(gui,~,~)
% Syntax:
%
% createDummy(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open a dialog window to create a dummy variable.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    methodgui = nb_createDummyGUI(gui.parent,gui.data);
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);

end
