function varSelCallback(gui,hObject,~)
% Syntax:
%
% varSelCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    value  = get(hObject,'value');
    vars   = string(value);
    set(gui.optionPanelComponents.dependentBox,'string',vars,'value',1);

end
