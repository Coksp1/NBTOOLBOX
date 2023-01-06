function getMethodList(gui,~,~)
% Syntax:
%
% getMethodList(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Create the window to show and edit the method calls
    methodgui = nb_methodCallsGUI(gui.parent,gui.data);
    
    % Add a listener to the nb_methodGUI object, will update the data
    % of the spreadsheet and create a backup
    if isvalid(methodgui)
        addlistener(methodgui,'methodFinished',@gui.updateDataCallback);
    end


end
