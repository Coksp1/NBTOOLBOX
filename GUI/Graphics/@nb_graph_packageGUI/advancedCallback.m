function advancedCallback(gui,hObject,~) 
% Syntax:
%
% advancedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'checked');
    if strcmpi(string,'on')
        set(hObject,'checked','off');
        gui.package.advanced = 0;
    else
        set(hObject,'checked','on');
        gui.package.advanced = 1;
    end

    gui.changed = 1;
    
end
