function allCallback(gui,hObject,~)
% Syntax:
%
% allCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    value = get(hObject,'value');
    if value
        defaultBackground = get(0,'defaultUicontrolBackgroundColor');
        set(gui.list1,'enable','off','background',defaultBackground);
    else
        set(gui.list1,'enable','on','background',[1 1 1]);
    end
       
end
