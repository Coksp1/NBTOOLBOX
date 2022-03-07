function createVariable(gui,~,~)
% Syntax:
%
% createVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open a dialog window to create a variable. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    methodgui = nb_createVariableGUI(gui.parent,gui.data,'variable');
    addlistener(methodgui,'methodFinished',@gui.updateDataCallback);

end
