function changeSource(gui,hObject,~)
% Syntax:
%
% changeSource(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    index  = get(hObject,'value');
    src    = string{index};
    
    % Update the GUI properties holding info on specific obj
    gui.currSource = src;
    
    % Update Panel
    fillPanelGUI(gui);

end
