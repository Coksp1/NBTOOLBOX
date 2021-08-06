function changeVariable(gui,hObject,~)
% Syntax:
%
% changeVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Called when variable is changed
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string   = get(hObject,'string');
    index    = get(hObject,'value');
    variable = string{index};

    % Update the GUI with the option for the new variable
    updateGUI(gui,variable,1);

end
