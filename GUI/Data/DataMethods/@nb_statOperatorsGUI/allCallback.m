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
    dim   = nb_getUIControlValue(gui.comp.dim,'userdata');
    if value
        defaultBackground = get(0,'defaultUicontrolBackgroundColor');
        set(gui.comp.variables,'enable','off','background',defaultBackground);
    else
        dim = nb_getUIControlValue(gui.comp.dim,'userdata');
        if dim ~= 3
            set(gui.comp.variables,'enable','on','background',[1 1 1]);
        end
    end
    
    if ~value && dim == 1
        set(gui.comp.start,'enable','on');
        set(gui.comp.finish,'enable','on');
    else
        set(gui.comp.start,'enable','off');
        set(gui.comp.finish,'enable','off');
    end
       
end
