function getSource(gui,~,~)
% Syntax:
%
% getSource(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.page)
        gui.page = 1;
    end
    guiSource = nb_dataSourceGUI(gui.parent,gui.data);
    if isvalid(guiSource)
        addlistener(guiSource,'methodFinished',@gui.updateDataCallback);
    end
    
end
