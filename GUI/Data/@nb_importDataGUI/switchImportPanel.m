function switchImportPanel(gui,~,~)
% Syntax:
%
% switchImportPanel(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Changes between panels in the import window. Switches between the 
% initial and the advanced panel.
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isequal(gui.currentPanel,gui.initSelectPanel)
        set(gui.currentPanel,'Visible','off');
        gui.currentPanel = gui.advSelectPanel;
        set(gui.currentPanel,'Visible','on');
        set(gui.customSpec,'value',0);
        importRadioCallback(gui,[],[]);
    else 
        set(gui.currentPanel,'Visible','off');
        gui.currentPanel = gui.initSelectPanel;
        set(gui.currentPanel,'Visible','on');
        set(gui.customSpec,'value',0);
        importRadioCallback(gui,[],[]);
    end
    updateTable(gui);
    
end

