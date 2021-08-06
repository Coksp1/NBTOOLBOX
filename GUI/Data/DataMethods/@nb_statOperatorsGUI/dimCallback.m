function dimCallback(gui,hObject,~)
% Syntax:
%
% dimCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_cs')
        return
    end

    value = nb_getUIControlValue(hObject,'userdata');
    all   = nb_getUIControlValue(gui.comp.all);
    if value == 1 && ~all 
        set(gui.comp.start,'enable','on');
        set(gui.comp.finish,'enable','on');
        set(gui.comp.postfix,'enable','on');
    else
        set(gui.comp.start,'enable','off');
        set(gui.comp.finish,'enable','off');
        set(gui.comp.postfix,'enable','off');
    end
    
    if value == 3 || all 
        defaultBackground = get(0,'defaultUicontrolBackgroundColor');
        set(gui.comp.variables,'enable','off','background',defaultBackground)
    else    
        set(gui.comp.variables,'enable','on','background',[1,1,1])
    end
    
end
