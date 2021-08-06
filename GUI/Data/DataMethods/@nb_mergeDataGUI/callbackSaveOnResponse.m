function callbackSaveOnResponse(gui,hObject,~,mergedData)
% Syntax:
%
% callbackSaveOnResponse(gui,hObject,event,mergedData)
%
% Description:
%
% Part of DAG. Callback function called when variables or types of the
% merged datasets are conflicting
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    gui.data = mergedData;
    storeToGUI(gui);

    close(get(hObject,'parent'));

end
