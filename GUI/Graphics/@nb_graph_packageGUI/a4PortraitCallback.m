function a4PortraitCallback(gui,hObject,~) 
% Syntax:
%
% a4PortraitCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string = get(hObject,'checked');
    if strcmpi(string,'on')
        set(hObject,'checked','off');
        gui.package.a4Portrait = 0;
    else
        set(hObject,'checked','on');
        gui.package.a4Portrait = 1;
    end

    gui.changed = 1;
    
end
