function changeObj(gui,hObject,~)
% Syntax:
%
% changeObj(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    index  = get(hObject,'value');
    iden   = string{index};
    
    % Update the GUI properties holding info on specific obj
    gui.name       = iden;
    gui.currSource = 'Source_1'; 
    
    % Call from addListGUI in the change. Window and popupmenu remains 
    % constant
    addSourcesGUI(gui);

end
